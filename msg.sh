#!/bin/sh

query=$1

result=$(sqlite3 ~/Library/Messages/chat.db "SELECT text || '|' || is_read FROM message WHERE text LIKE '%验证码%' ORDER BY date DESC LIMIT 5;")

json="{\"items\":["
index=0
IFS=$'\n'
for item in $result; do
    title=$(echo "$item" | cut -d'|' -f1)
    is_read=$(echo "$item" | cut -d'|' -f2)
    code=$(echo "$title" | grep -oE '\d{4,}')

    if [ "$is_read" = "1" ]; then
        title="✅ $title"
    else
        title="📩 $title"
    fi

    if [ $index -ne 0 ]; then
        json="$json,"
    fi
    json="$json{\"title\":\"$title\",\"arg\":\"$code\"}"
    index=$((index + 1))
done
json="$json]}"

# for Alfred
echo "$json"