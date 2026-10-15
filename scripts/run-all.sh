#!/usr/bin/env bash
#
# run-all.sh — последовательный запуск всех шагов первоначальной настройки сервера.
# Шаг с SSH вынесен в интерактивное подтверждение, чтобы не потерять доступ
# к серверу по невнимательности.
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Запустите с правами root (sudo bash run-all.sh <username>)" >&2
    exit 1
fi

USERNAME="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${USERNAME}" ]]; then
    echo "Использование: $0 <username>" >&2
    exit 1
fi

echo "===== Шаг 1/5: создание пользователя ====="
bash "${SCRIPT_DIR}/01-create-user.sh" "${USERNAME}"

echo ""
echo "===== Шаг 2/5: настройка SSH ====="
echo "Перед продолжением скопируйте публичный ключ командой:"
echo "    ssh-copy-id ${USERNAME}@<IP-сервера>"
echo "и проверьте вход по ключу в отдельном терминале."
read -r -p "Продолжить настройку SSH-хардненинга сейчас? (yes/no): " PROCEED
if [[ "${PROCEED}" == "yes" ]]; then
    bash "${SCRIPT_DIR}/02-ssh-hardening.sh"
else
    echo "Шаг 2 пропущен. Запустите scripts/02-ssh-hardening.sh вручную позже."
fi

echo ""
echo "===== Шаг 3/5: файрвол ====="
bash "${SCRIPT_DIR}/03-firewall.sh"

echo ""
echo "===== Шаг 4/5: fail2ban ====="
bash "${SCRIPT_DIR}/04-fail2ban.sh"

echo ""
echo "===== Шаг 5/5: веб-сервер ====="
bash "${SCRIPT_DIR}/05-webserver.sh"

echo ""
echo "===== Настройка сервера завершена ====="
