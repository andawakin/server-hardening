#!/usr/bin/env bash
#
# 02-ssh-hardening.sh — отключение входа по паролю и под root.
#
# ВАЖНО: перед запуском убедитесь, что вход по SSH-ключу под обычным
# пользователем уже работает (проверьте в отдельном терминале!),
# иначе рискуете потерять доступ к серверу.
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Запустите с правами root (sudo bash 02-ssh-hardening.sh)" >&2
    exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)"

read -r -p "Вы проверили вход по SSH-ключу под обычным пользователем в ДРУГОМ терминале? (yes/no): " CONFIRM
if [[ "${CONFIRM}" != "yes" ]]; then
    echo "Отменено. Сначала проверьте вход по ключу, затем запустите скрипт снова."
    exit 1
fi

echo "[*] Создание резервной копии ${SSHD_CONFIG} -> ${BACKUP}"
cp "${SSHD_CONFIG}" "${BACKUP}"

set_sshd_option() {
    local key="$1"
    local value="$2"
    if grep -qE "^\s*#?\s*${key}\s+" "${SSHD_CONFIG}"; then
        sed -i -E "s|^\s*#?\s*${key}\s+.*|${key} ${value}|" "${SSHD_CONFIG}"
    else
        echo "${key} ${value}" >> "${SSHD_CONFIG}"
    fi
}

echo "[*] Применение настроек sshd_config..."
set_sshd_option "PasswordAuthentication" "no"
set_sshd_option "PermitRootLogin" "no"
set_sshd_option "PubkeyAuthentication" "yes"
set_sshd_option "ChallengeResponseAuthentication" "no"

echo "[*] Проверка синтаксиса конфигурации..."
sshd -t

echo "[*] Перезапуск sshd..."
systemctl restart sshd

echo ""
echo "Готово. Вход по паролю и под root отключён."
echo "Резервная копия исходного конфига: ${BACKUP}"
echo ""
echo "Текущие параметры:"
sshd -T | grep -E "passwordauthentication|permitrootlogin|pubkeyauthentication"
