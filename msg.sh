#!/bin/sh

query=$1

result=$(sqlite3 ~/Library/Messages/chat.db "SELECT text || '|' || is_read FROM message WHERE text LIKE '%验证码%' ORDER BY date DESC LIMIT 5;")

json="{\"items\":["
index=0
IFS=$'\n'
for item in $result; do
    msg=$(echo "$item" | cut -d'|' -f1)
    is_read=$(echo "$item" | cut -d'|' -f2)
    code=$(echo "$msg" | grep -oE '\d{4,}' | tr '\n' ',' | sed 's/,$//')

    if [ "$is_read" = "1" ]; then
        msg="✅ $msg"
    else
        msg="📩 $msg"
    fi

    if [ $index -ne 0 ]; then
        json="$json,"
    fi
    json="$json{\"title\":\"$code\",\"subtitle\":\"$msg\",\"arg\":\"$code\"}"
    index=$((index + 1))
done
json="$json]}"

# for Alfred
echo "$json"