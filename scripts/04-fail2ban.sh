#!/usr/bin/env bash
#
# 04-fail2ban.sh — установка и базовая настройка fail2ban для защиты SSH.
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Запустите с правами root (sudo bash 04-fail2ban.sh)" >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[*] Установка fail2ban..."
apt update -y
apt install -y fail2ban

echo "[*] Копирование конфигурации jail.local..."
cp "${REPO_ROOT}/configs/jail.local" /etc/fail2ban/jail.local

echo "[*] Перезапуск и включение автозапуска fail2ban..."
systemctl enable fail2ban
systemctl restart fail2ban

echo ""
echo "Готово. Статус jail для SSH:"
sleep 2
fail2ban-client status sshd || true
