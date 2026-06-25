#!/bin/bash
# 执行命令并在失败时通过飞书 Webhook 发送通知

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/common/help.sh"

usage() {
    cat <<'EOF'
用法: croncheck <command> [args...]

执行给定命令；若退出码非 0，向配置的飞书 Webhook 发送失败通知。
最终以原命令的退出码退出。

选项:
  -h, --help  显示此帮助

示例:
  croncheck /path/to/backup.sh
  croncheck docker compose up -d
EOF
}

dotfile_help_requested "${1:-}" && dotfile_show_help

if [ "$#" -lt 1 ]; then
    echo "错误: 缺少要执行的命令" >&2
    usage
    exit 1
fi

WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/808eafd8-a79f-4af0-b730-8442cf15933b"

OUTPUT=$("$@" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    JSON_DATA=$(cat <<EOF
{
    "msg_type": "text",
    "content": {
         "text": "Cron job fail\n\nCommand: $*\nError: $(echo "$OUTPUT" | sed 's/"/\\"/g')"
    }
}
EOF
)
    curl -s -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$WEBHOOK_URL"
fi

exit $EXIT_CODE
