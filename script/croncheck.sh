#!/bin/bash

# 检查参数数量
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <command> [command_args...]"
    exit 1
fi

# 获取 webhook URL
WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/808eafd8-a79f-4af0-b730-8442cf15933b"

# 执行命令并捕获输出
OUTPUT=$("$@" 2>&1)
EXIT_CODE=$?

# 如果命令失败，发送 webhook 通知
if [ $EXIT_CODE -ne 0 ]; then
    # 准备 JSON 数据
    JSON_DATA=$(cat <<EOF
{
    "msg_type": "text",
    "content": {
         "text": "Cron job fail\n\nCommand: $*\nError: $(echo "$OUTPUT" | sed 's/"/\\"/g')"
    }
}
EOF
)
    # 发送 webhook
    curl -s -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$WEBHOOK_URL"
fi

# 退出，使用原命令的退出码
exit $EXIT_CODE

