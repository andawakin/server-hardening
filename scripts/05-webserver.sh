#!/usr/bin/env bash
#
# 05-webserver.sh — установка и запуск nginx с автозапуском.
# Подробная настройка статической страницы — в отдельном репозитории
# nginx-static-server.
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Запустите с правами root (sudo bash 05-webserver.sh)" >&2
    exit 1
fi

echo "[*] Установка nginx..."
apt update -y
apt install -y nginx

echo "[*] Включение автозапуска и старт сервиса..."
systemctl enable nginx
systemctl start nginx

echo ""
echo "Готово. Статус nginx:"
systemctl is-enabled nginx
curl -sI http://localhost | head -n 1
