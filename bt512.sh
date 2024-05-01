#!/bin/bash

file_path="/www/server/panel/class/panelPlugin.py"

# 找到包含 self.check_mem_limit(versionInfo['mem_limit']) 的行号
start_line=$(grep -n "self\.check_mem_limit(versionInfo\['mem_limit'\])" "$file_path" | cut -d: -f1)

if [ -z "$start_line" ]; then
    echo "Pattern not found in file: $file_path"
    exit 1
fi

# 注释掉这一行，并从该行开始注释掉6行
sed -i "${start_line}s/^/#/" "$file_path"
sed -i "${start_line},$(($start_line+5))s/^/#/" "$file_path"

echo "Lines commented successfully from line $start_line in $file_path"
# 重启宝塔面板
service bt restart
