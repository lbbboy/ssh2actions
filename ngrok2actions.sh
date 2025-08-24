#!/usr/bin/env bash

# 检查环境变量
if [[ -z "${NGROK_TOKEN}" ]]; then
  echo "请设置 'NGROK_TOKEN' 环境变量。"
  exit 2
fi

if [[ -z "${SSH_PASSWORD}" && -z "${SSH_PUBKEY}" && -z "${GH_SSH_PUBKEY}" ]]; then
  echo "请设置 'SSH_PASSWORD' 环境变量。"
  exit 3
fi

# 安装 ngrok
echo "安装 ngrok ..."
curl -fsSL https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -o ngrok.zip
unzip ngrok.zip
chmod +x ngrok
sudo mv ngrok /usr/local/bin
rm ngrok.zip

# 配置 SSH 密码
if [[ -n "${SSH_PASSWORD}" ]]; then
  echo "设置用户密码 ..."
  echo -e "${SSH_PASSWORD}\n${SSH_PASSWORD}" | sudo passwd "${USER}"
fi

# 启动 ngrok 代理
echo "启动 ngrok 代理 ..."
screen -dmS ngrok ngrok tcp 22 --log /tmp/ngrok.log --authtoken "${NGROK_TOKEN}" --region "${NGROK_REGION:-us}"

# 等待 ngrok 启动
sleep 10

# 获取 SSH 连接命令
SSH_CMD=$(grep -oE "tcp://(.+)" /tmp/ngrok.log | sed "s/tcp:\/\//ssh ${USER}@/" | sed "s/:/ -p /")
echo "SSH 连接命令：${SSH_CMD}"
