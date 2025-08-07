#!/bin/bash

set -e

echo "🔍 当前系统版本："
cat /etc/os-release
echo "✅ 确保你是 Debian 12 (bookworm)..."

read -p "是否继续升级到 Debian 13 (Trixie)? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ 用户取消操作"
    exit 1
fi

echo "📦 开始更新现有系统..."
apt update && apt upgrade -y && apt full-upgrade -y && apt autoremove --purge -y

echo "📝 修改 /etc/apt/sources.list ..."
sed -i 's/bookworm/trixie/g' /etc/apt/sources.list

echo "📦 更新 APT 索引..."
apt update

echo "🚀 开始升级到 Debian 13..."
apt upgrade --without-new-pkgs -y
apt full-upgrade -y

echo "🧹 清理不再需要的软件..."
apt autoremove --purge -y

echo "🔁 升级完成，重启生效！"
read -p "是否现在重启系统？[y/N]: " reboot_now
if [[ "$reboot_now" == "y" || "$reboot_now" == "Y" ]]; then
    reboot
else
    echo "⏳ 请稍后手动重启系统以完成升级。"
fi
