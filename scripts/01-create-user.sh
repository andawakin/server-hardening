#!/usr/bin/env bash
#
# 01-create-user.sh — создание непривилегированного пользователя с sudo-правами.
# Использование: sudo bash 01-create-user.sh <username>
#
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Запустите с правами root (sudo bash 01-create-user.sh <username>)" >&2
    exit 1
fi

USERNAME="${1:-}"

if [[ -z "${USERNAME}" ]]; then
    echo "Использование: $0 <username>" >&2
    exit 1
fi

if id "${USERNAME}" &>/dev/null; then
    echo "Пользователь ${USERNAME} уже существует, пропускаю создание."
else
    echo "[*] Создание пользователя ${USERNAME}..."
    adduser --gecos "" "${USERNAME}"
fi

echo "[*] Добавление ${USERNAME} в группу sudo..."
usermod -aG sudo "${USERNAME}"

echo "[*] Настройка директории ~/.ssh..."
USER_HOME=$(eval echo "~${USERNAME}")
mkdir -p "${USER_HOME}/.ssh"
touch "${USER_HOME}/.ssh/authorized_keys"
chmod 700 "${USER_HOME}/.ssh"
chmod 600 "${USER_HOME}/.ssh/authorized_keys"
chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}/.ssh"

echo ""
echo "Готово. Пользователь ${USERNAME} создан и добавлен в sudo."
echo "Теперь на своей машине выполните:"
echo "    ssh-copy-id ${USERNAME}@<IP-сервера>"
echo "и убедитесь, что вход по ключу работает, прежде чем продолжать хардненинг SSH."
