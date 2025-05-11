#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: 参数为你的域名！"
    echo "Usage: $0 domain"
    exit 1
fi

domain=$1
username=$(whoami)
random_port=$((RANDOM % 40001 + 20000))  


echo "to /home/$username/domains/$domain/public_html/index.js"
curl -s -o "/home/$username/domains/$domain/public_html/index.js" "https://github.com/fxlqwq/node-ws/raw/refs/heads/main/index.js"
if [ $? -ne 0 ]; then
    echo "Error: 下载脚本 index.js 失败！"
    exit 1
fi

curl -s -o "/home/$username/cron.sh" "https://raw.githubusercontent.com/frankiejun/node-ws/main/cron.sh"
if [ $? -ne 0 ]; then
    echo "Error: 下载脚本 cron.sh 失败！"
    exit 1
fi
chmod +x /home/$username/cron.sh



sed -i "s/1234.abc.com/$domain/g" "/home/$username/domains/$domain/public_html/index.js"
sed -i "s/3000;/$random_port;/g" "/home/$username/domains/$domain/public_html/index.js"


cat > "/home/$username/domains/$domain/public_html/package.json" << EOF
{
  "name": "node-ws",
  "version": "1.0.0",
  "description": "Node.js Server",
  "main": "index.js",
  "author": "eoovve",
  "repository": "https://github.com/eoovve/node-ws",
  "license": "MIT",
  "private": false,
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "ws": "^8.14.2",
    "axios": "^1.6.2"
  },
  "engines": {
    "node": ">=14"
  }
}
EOF

echo "*/1 * * * * /home/$username/cron.sh" > ./mycron
crontab ./mycron >/dev/null 2>&1
rm ./mycron

echo "安装完毕" 
