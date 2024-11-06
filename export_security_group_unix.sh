#!/bin/bash

# 安全组 ID 填写需要复制的安全组ID
SGID="sg-034a9e2c84XXXXXXX"

# 输出文件名
OUTPUT_FILE="security-group.json"

# 使用 AWS CLI 描述安全组并导出到文件
aws ec2 describe-security-groups --group-ids $SGID > $OUTPUT_FILE

if [ $? -eq 0 ]; then
    echo "Security group exported to $OUTPUT_FILE"
else
    echo "Failed to export security group"
fi