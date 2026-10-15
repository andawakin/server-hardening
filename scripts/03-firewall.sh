#!/usr/bin/env bash
#
# 03-firewall.sh — настройка ufw: открываем только необходимые порты.
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Запустите с правами root (sudo bash 03-firewall.sh)" >&2
    exit 1
fi

echo "[*] Установка ufw (если не установлен)..."
apt update -y
apt install -y ufw

echo "[*] Настройка политики по умолчанию: запрет входящих, разрешение исходящих..."
ufw default deny incoming
ufw default allow outgoing

echo "[*] Открытие необходимых портов: SSH (22), HTTP (80), HTTPS (443)..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

echo "[*] Включение ufw..."
ufw --force enable

echo ""
echo "Готово. Текущий статус файрвола:"
ufw status verbose
