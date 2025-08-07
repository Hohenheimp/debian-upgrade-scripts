#!/bin/bash

set -e

# 检查是否以 root 权限运行
if [[ $EUID -ne 0 ]]; then
    echo "❌ 此脚本需要 root 权限运行，请使用 sudo"
    exit 1
fi

# 日志文件
LOG_FILE="/var/log/debian_upgrade_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "🔍 当前系统版本："
cat /etc/os-release
echo "✅ 确保你是 Debian 12 (bookworm)..."

# 用户确认
read -p "是否继续升级到 Debian 13 (Trixie)? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "❌ 用户取消操作"
    exit 1
fi

echo "📦 开始更新现有系统..."
if ! apt update; then
    echo "❌ APT 更新失败，请检查网络或 sources.list"
    exit 1
fi
apt upgrade -y && apt full-upgrade -y && apt autoremove --purge -y

echo "📝 备份 /etc/apt/sources.list ..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak-$(date +%Y%m%d_%H%M%S)
echo "📝 修改 /etc/apt/sources.list ..."
sed -i 's/bookworm/trixie/g' /etc/apt/sources.list

echo "📦 更新 APT 索引..."
if ! apt update; then
    echo "❌ APT 索引更新失败，请检查 sources.list"
    exit 1
fi

echo "🚀 开始升级到 Debian 13..."
if ! apt upgrade --without-new-pkgs -y; then
    echo "❌ 升级失败，请检查日志 $LOG_FILE"
    exit 1
fi
if ! apt full-upgrade -y; then
    echo "❌ 完全升级失败，请检查日志 $LOG_FILE"
    exit 1
fi

echo "🧹 清理不再需要的软件..."
apt autoremove --purge -y

echo "🔁 升级完成，重启生效！"
echo "📜 日志已保存至 $LOG_FILE"
read -p "是否现在重启系统？[y/N]: " reboot_now
if [[ "$reboot_now" == "y" || "$reboot_now" == "Y" ]]; then
    reboot
else
    echo "⏳ 请稍后手动重启系统以完成升级。"
fi
