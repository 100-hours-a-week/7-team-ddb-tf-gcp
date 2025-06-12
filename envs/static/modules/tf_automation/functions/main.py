import base64
import json
import os
import requests

START_STATUSES = ["WORKING"]
END_STATUSES = ["SUCCESS", "FAILURE", "TIMEOUT", "INTERNAL_ERROR", "CANCELLED"]

STATUS_COLOR = {
    "QUEUED": 0xFFA500,          # 주황색
    "WORKING": 0x1E90FF,         # 파란색
    "SUCCESS": 0x2ECC71,         # 초록색
    "FAILURE": 0xE74C3C,         # 빨간색
    "TIMEOUT": 0xF39C12,         # 노란색
    "INTERNAL_ERROR": 0x9B59B6,  # 보라색
    "CANCELLED": 0x95A5A6        # 회색
}

def send_embed_to_discord(status, build_id, log_url, webhook_url, trigger_path, trigger_action):
    color = STATUS_COLOR.get(status, 0xCCCCCC)
    
    embed = {
        "title": f"Cloud Build : {trigger_path} {trigger_action}",
        "description": f"🔗 [로그 보기]({log_url})",
        "color": color,
        "fields": [
            {"name": "📦 Build ID", "value": build_id, "inline": False},
            {"name": "📊 상태", "value": status, "inline": True},
        ]
    }

    payload = {
        "username": "Cloud Build",
        "embeds": [embed]
    }

    response = requests.post(webhook_url, json=payload)
    print(f"✅ Discord responded with {response.status_code}")
    response.raise_for_status()

def main(event, context):
    try:
        payload = base64.b64decode(event['data']).decode("utf-8")
        build = json.loads(payload)
        trigger_path = build.get("substitutions", {}).get("_PATH", "unknown")
        trigger_action = build.get("substitutions", {}).get("_ACTION", "unknown")
        status = build.get("status", "")
        build_id = build.get("id", "N/A")
        log_url = build.get("logUrl", "")
        webhook_url = os.environ.get("DISCORD_WEBHOOK_URL")

        if status in START_STATUSES + END_STATUSES:
            send_embed_to_discord(status, build_id, log_url, webhook_url, trigger_path, trigger_action)
        else:
            print(f"⏩ Skipped status: {status}")
            return "Skipped"

        return "OK"

    except Exception as e:
        print(f"❌ Error: {e}")
        return "Error"
