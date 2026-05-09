#!/bin/bash
# 切换 CN_REGION 环境变量
# cn ↔ intl 切换

if [ "$CN_REGION" = "1" ]; then
    export CN_REGION=0
    echo "[INFO] Region switched to: 0 (国外)"
else
    export CN_REGION=1
    echo "[INFO] Region switched to: 1 (国内)"
fi

