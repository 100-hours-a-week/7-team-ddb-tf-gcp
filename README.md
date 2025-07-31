# 7-team-ddb AWS Terraform

Dolpin 서비스의 GCP 인프라를 Terraform으로 관리하는 코드 저장소입니다.

## 프로젝트 개요

- GCP 기반의 백엔드/프론트엔드/AI 인프라를 코드화하여 구성합니다.
- Cloud SQL, Cloud Storage, Artifact Registry, NAT Gateway 등 주요 리소스를 자동화합니다.

## 빠른 시작

### Terraform 초기화 및 적용

```bash
# 원격 상태(S3 Bucket) 설정
GCP에 S3 생성

# 환경별 프로비저닝 (static → shared → (dev/prod) 순서, loadtest는 부하테스트 전용)
cd ../envs/
terraform init && terraform apply

```

### 핵심 인프라 구성

### 

네트워크: VPC, Subnet, Peering, NAT, Cloud VPN

도메인 : Cloud DNS, Google Managed SSL Certificaion

컴퓨팅: Compute Engine, MIG, ALB

컨테이너 및 배포: Docker, ASG, Jenkins

데이터베이스: Cloud SQL

정적 자산 관리: CLoud Storage + Cloud CDN

모니터링: Prometheus, Grafana, Loki, Thanos, CLoud Storage, Node Exporter, Promtail

비용 최적화 및 알림 : CloudBuild, Cloud Scheduler, Discord

### 문서(Wiki)

[Cloud 아키텍처 설계 및 운영 가이드](https://github.com/100-hours-a-week/7-team-ddb-wiki/wiki/1.-Cloud-Wiki)

### 디렉토리 구성

```bash
.github/
envs/
  ├── dev/
  ├── prod/
  ├── shared/
  ├── static/
  └── loadtest/
modules/
  ├── ai/
  ├── be/
  ├── cloud_sql/
  ├── cloud_storage/
  ├── dns/
  ├── fe/
  ├── gar/
  ├── nat_gateway/
  ├── network/
  └── vpc_peering/
secrets/
.gitignore
.gitmessage.txt
```
