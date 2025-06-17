# Pub/Sub 토픽: Scheduler 메시지 큐
resource "google_pubsub_topic" "tf_scheduler_topic" {
  name = "tf-scheduler-topic-${var.env}"
}

# Cloud Scheduler Job: Pub/Sub으로 Terraform 트리거
resource "google_cloud_scheduler_job" "tf_scheduler_jobs" {
  for_each = local.flat_schedules

  name      = "tf-${each.key}"
  schedule  = each.value.schedule
  time_zone = "Asia/Seoul"

  pubsub_target {
    topic_name = google_pubsub_topic.tf_scheduler_topic.id
    attributes = {
      branch          = each.value.branch
      action          = each.value.action
      path            = each.value.branch == "main" ? "prod" : each.value.branch
      dbinstance      = var.envs_parameter[each.value.branch == "main" ? "prod" : each.value.branch].db_instance
      dbname          = var.envs_parameter[each.value.branch == "main" ? "prod" : each.value.branch].db_name
      cloudstorage    = var.envs_parameter[each.value.branch == "main" ? "prod" : each.value.branch].cloudstorage
      dbpwdsecretname = var.envs_parameter[each.value.branch == "main" ? "prod" : each.value.branch].dbpwdsecretname
      dbuser          = var.envs_parameter[each.value.branch == "main" ? "prod" : each.value.branch].dbuser
    }
  }
}

# GCS 백업 버킷 생성
resource "google_storage_bucket" "backup_bucket" {
  name     = var.backup_bucket_name
  location = var.bucket_location

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  labels = {
    name        = "${var.env}-backup-bucket"
    environment = var.env
    component   = "backup"
    type        = "gcs"
    managed_by  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Cloud Build Trigger: Pub/Sub 구독하여 Terraform 실행
resource "google_cloudbuild_trigger" "tf_build_trigger" {
  name        = "tf-${var.env}"
  description = "Terraform automation"

  pubsub_config {
    topic = google_pubsub_topic.tf_scheduler_topic.id
  }
  substitutions = {
    _BRANCH         = "$(body.message.attributes.branch)"
    _ACTION         = "$(body.message.attributes.action)"
    _PATH           = "$(body.message.attributes.path)"
    _DBINSTANCE     = "$(body.message.attributes.dbinstance)"
    _DBNAME         = "$(body.message.attributes.dbname)"
    _DBPWSECRETNAME = "$(body.message.attributes.dbpwdsecretname)"
    _CLOUDSTORAGE   = "$(body.message.attributes.cloudstorage)"
    _DBUSER         = "$(body.message.attributes.dbuser)"
  }

  service_account = google_service_account.build_sa.id

  build {
    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
    step {
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args = [
        "-c",
        <<-EOF
        git clone --branch=$${_BRANCH} --single-branch ${var.repo_url} repo
        git clone --branch=main --single-branch ${var.repo_url} prod
        git clone --branch=dev --single-branch ${var.repo_url} dev
        EOF
      ]
    }
    # Secret 세팅
    step {
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
      entrypoint = "bash"
      args = [
        "-c",
        <<-EOF
          # 클론 전에 워크스페이스 생성
          mkdir -p /workspace/repo/secrets \
          /workspace/dev/secrets \
          /workspace/prod/secrets

          # Secret Manager 에서 키 가져오기
          gcloud secrets versions access latest --secret="${var.account_key_name}" \
            --format='get(payload.data)' | tr '_-' '/+' | base64 -d | \
            tee /workspace/repo/secrets/account.json \
            /workspace/dev/secrets/account.json \
            /workspace/prod/secrets/account.json \
            > /dev/null
        EOF
      ]
    }
    # Terraform init
    step {
      name       = "hashicorp/terraform:1.11.4"
      entrypoint = "sh"
      args = [
        "-c",
        <<-EOF
        cd /workspace/repo/envs/$${_PATH} && terraform init
        cd /workspace/dev/envs/dev && terraform init
        cd /workspace/prod/envs/prod && terraform init
        cd /workspace/dev/envs/shared && terraform init
        EOF
      ]
    }
    # Backup on destroy
    step {
      name       = "google/cloud-sdk:slim"
      entrypoint = "bash"
      args = ["-c",
        <<-EOF
        set -e
        if [ "$${_ACTION}" = "destroy" ]; then
          TS=$$(date +%Y%m%d_%H%M%S)

          # DB Export
          gcloud sql export sql $${_DBINSTANCE} \
            "gs://${google_storage_bucket.backup_bucket.name}/$${_PATH}/db/db_backup_$$TS.sql" \
            --database=$${_DBNAME} --quiet

          # Storage backup
          gsutil -m rsync -r \
            "gs://$${_CLOUDSTORAGE}" \
            "gs://${google_storage_bucket.backup_bucket.name}/$${_PATH}/storage/storage_backup_$$TS/"
        fi
        EOF
      ]
    }

    step {
      name       = "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
      entrypoint = "bash"
      args = ["-c",
        <<-EOF
        set -e
        if [ "$${_ACTION}" = "destroy" ]; then
          apt-get update && apt-get install -y postgresql-client wget
          wget -qO /usr/local/bin/cloud_sql_proxy \
          https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 && \
          chmod +x /usr/local/bin/cloud_sql_proxy
          /usr/local/bin/cloud_sql_proxy \
          -dir=/cloudsql \
          -instances=velvety-calling-458402-c1:asia-northeast3:$${_DBINSTANCE} \
          -credential_file=/workspace/repo/secrets/account.json &
          sleep 5 
          export PGPASSWORD="$(gcloud secrets versions access latest --secret="$${_DBPWSECRETNAME}")"
          psql \
          -h "/cloudsql/${var.project_id}:${var.region}:$${_DBINSTANCE}" \
          -U "$${_DBUSER}" \
          -d "$${_DBNAME}" \
          -c "REVOKE CONNECT ON DATABASE $${_DBNAME} FROM public;
              REVOKE CONNECT ON DATABASE $${_DBNAME} FROM $${_DBUSER};
              SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$${_DBNAME}' AND pid <> pg_backend_pid();
              ALTER ROLE $${_DBUSER} NOLOGIN;"
          kill $!
        fi
        EOF
      ]
    }

    step {
      name       = "hashicorp/terraform:1.11.4"
      entrypoint = "sh"
      args = [
        "-c",
        <<-EOF
        set -e
        if [ "$${_ACTION}" = "apply" ]; then
          cd /workspace/dev/envs/shared && terraform apply -auto-approve
        fi
        EOF
      ]
    }

    # Terraform apply/destroy
    step {
      name       = "hashicorp/terraform:1.11.4"
      entrypoint = "sh"
      args = [
        "-c",
        <<-EOF
        set -e
        if [ "$${_ACTION}" = "destroy" ] || [ "$${_ACTION}" = "apply" ]; then
          cd repo/envs/$${_PATH} && terraform $${_ACTION} -auto-approve
        fi
        EOF
      ]
    }

    step {
      name       = "hashicorp/terraform:1.11.4"
      entrypoint = "sh"
      args = [
        "-c",
        <<-EOF
        set -e
        if [ "$${_ACTION}" = "destroy" ]; then
          BOTH_DESTROYED=true
          cd /workspace/prod/envs/prod
          PROD_COUNT=$$(terraform state list | wc -l)
          cd /workspace/dev/envs/dev
          DEV_COUNT=$$(terraform state list | wc -l)
          if [ "$$PROD_COUNT" -eq 0 ] && [ "$$DEV_COUNT" -eq 0 ]; then
            cd /workspace/dev/envs/shared
            terraform destroy -auto-approve
          fi
        fi
        EOF
      ]
    }

    step {
      name       = "google/cloud-sdk:slim"
      entrypoint = "bash"
      args = ["-c",
        <<-EOF
        set -e
        if [ "$${_ACTION}" = "apply" ]; then
          # Latest storage backup
          LATEST_STORAGE_PREFIX=$$( \
            gsutil ls -d "gs://${google_storage_bucket.backup_bucket.name}/$${_PATH}/storage/*/" \
              | sort | tail -n1 \
          )
            gsutil -m rsync -r \
            "$$LATEST_STORAGE_PREFIX" \
            "gs://$${_CLOUDSTORAGE}/"
          # Latest DB dump
          LATEST_DB_URI=$$( \
            gsutil ls "gs://${google_storage_bucket.backup_bucket.name}/$${_PATH}/db/db_backup_*.sql" \
              | sort | tail -n1 \
          )
          gcloud sql import sql $${_DBINSTANCE} \
            "$$LATEST_DB_URI" \
            --database=$${_DBNAME} --quiet
        fi
        EOF
      ]
    }

    timeout = "1800s"
  }
}

# Scheduler(Pub/Sub 퍼블리셔) Secvice Account
resource "google_service_account" "scheduler_sa" {
  account_id   = "tf-scheduler-publisher"
  display_name = "SA for Cloud Scheduler to Pub/Sub"
}

# Scheduler Secvice Account에 pubsub publisher 권한 
resource "google_pubsub_topic_iam_binding" "allow_scheduler" {
  topic = google_pubsub_topic.tf_scheduler_topic.name
  role  = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${google_service_account.scheduler_sa.email}",
  ]
}
# Cloud Build 실행용 (Terraform Runner)
resource "google_service_account" "build_sa" {
  account_id   = "tf-build-runner"
  display_name = "SA for Terraform in Cloud Build"
}

# Pub/Sub IAM: Build 계정 구독 권한
resource "google_pubsub_topic_iam_binding" "build_sub" {
  topic = google_pubsub_topic.tf_scheduler_topic.name
  role  = "roles/pubsub.subscriber"
  members = [
    "serviceAccount:${google_service_account.build_sa.email}",
  ]
}

# Build 계정에 프로젝트 권한 일괄 부여
resource "google_project_iam_member" "build_sa" {
  for_each = {
    editor               = "roles/editor"
    log_writer           = "roles/logging.logWriter"
    secret_accessor      = "roles/secretmanager.admin"
    storage_admin        = "roles/storage.admin"
    cloudsql_admin       = "roles/cloudsql.admin"
    iap_tunnel           = "roles/iap.tunnelResourceAccessor"
    os_login             = "roles/compute.osLogin"
    compute_admin        = "roles/compute.admin"          # VM 관리
    service_account_user = "roles/iam.serviceAccountUser" # SA 사용
    project_viewer       = "roles/viewer"                 # 프로젝트 읽기
  }

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.build_sa.email}"
}

resource "google_storage_bucket" "tf_notifier_bucket" {
  name                        = "tf_notifier-${var.env}"
  location                    = var.bucket_location
  force_destroy               = true
  uniform_bucket_level_access = true
}

data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/functions"
  output_path = "${path.module}/function.zip"
}

# 3. ZIP 파일을 GCS에 업로드
resource "google_storage_bucket_object" "notifier_zip" {
  name   = "notifier.zip"
  bucket = google_storage_bucket.tf_notifier_bucket.name
  source = data.archive_file.function.output_path
}

data "google_secret_manager_secret_version" "discord_webhook" {
  secret  = "discord-webhook-url"
  version = "latest"
}

resource "google_cloudfunctions_function" "tf_notifier" {
  name                  = "tf-notifier"
  runtime               = "python310"
  entry_point           = "main"
  source_archive_bucket = google_storage_bucket.tf_notifier_bucket.name
  source_archive_object = google_storage_bucket_object.notifier_zip.name
  available_memory_mb   = 128
  timeout               = 60

  environment_variables = {
    DISCORD_WEBHOOK_URL =data.google_secret_manager_secret_version.discord_webhook.secret_data
  }
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = "projects/${var.project_id}/topics/cloud-builds"
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.tf_notifier.project
  region         = google_cloudfunctions_function.tf_notifier.region
  cloud_function = google_cloudfunctions_function.tf_notifier.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
