#!/bin/sh

query=$1

# 执行 SQLite 查询，获取最近 5 条包含 "验证码" 的消息记录，并包含 is_read 字段
result=$(sqlite3 ~/Library/Messages/chat.db "SELECT text || '|' || is_read FROM message WHERE text LIKE '%验证码%' ORDER BY date DESC LIMIT 5;")

# 使用正则提取签名、验证码和已读状态
items=$(echo "$result" | sed -E 's/(【[^】]*】)[^0-9]*([0-9]{4,8}).*\|([01])$/\1 验证码：\2|\2|\3/')

# 构建 JSON 格式的输出
json="{\"items\":["
index=0
IFS=$'\n'
for item in $items; do
    # 分割 title, code, 和 is_read
    title=$(echo "$item" | cut -d'|' -f1)
    code=$(echo "$item" | cut -d'|' -f2)
    is_read=$(echo "$item" | cut -d'|' -f3)

    # 根据 is_read 添加已读或未读标志
    if [ "$is_read" = "1" ]; then
        title="✅ $title"
    else
        title="📩 $title"
    fi

    # 防止最后一个元素后多余的逗号
    if [ $index -ne 0 ]; then
        json="$json,"
    fi
    json="$json{\"title\":\"$title\",\"arg\":\"$code\"}"
    index=$((index + 1))
done
json="$json]}"

# 输出 JSON 供 Alfred 使用
echo "$json"