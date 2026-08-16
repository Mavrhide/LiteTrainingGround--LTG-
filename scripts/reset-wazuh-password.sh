#!/bin/bash
set -e

NEW_PASSWORD="${1:?Использование: sudo bash reset-wazuh-password.sh 'ПарольЗдесь'}"
WAZUH_INSTALL_DIR="/home/vagrant"
DASHBOARD_CONF_DIR="/etc/wazuh-dashboard"
KEYSTORE_BIN="/usr/share/wazuh-dashboard/bin/opensearch-dashboards-keystore"

echo "== 1/4: Смена пароля admin и kibanaserver через официальный инструмент =="
cd "$WAZUH_INSTALL_DIR"
if [ ! -f wazuh-passwords-tool.sh ]; then
    curl -sO https://packages.wazuh.com/4.14/wazuh-passwords-tool.sh
fi
sudo bash wazuh-passwords-tool.sh -u admin -p "$NEW_PASSWORD"
sudo bash wazuh-passwords-tool.sh -u kibanaserver -p "$NEW_PASSWORD"

echo "== 2/4: Пересоздание keystore Wazuh Dashboard =="
cd "$DASHBOARD_CONF_DIR"
sudo systemctl stop wazuh-dashboard
sudo rm -f opensearch_dashboards.keystore
sudo "$KEYSTORE_BIN" create --allow-root
printf '%s' 'kibanaserver' | sudo "$KEYSTORE_BIN" add opensearch.username --stdin --allow-root
printf '%s' "$NEW_PASSWORD" | sudo "$KEYSTORE_BIN" add opensearch.password --stdin --allow-root
sudo chown wazuh-dashboard:wazuh-dashboard opensearch_dashboards.keystore

echo "== 3/4: Перезапуск сервисов в правильном порядке =="
sudo systemctl restart wazuh-indexer
sleep 30
sudo systemctl restart wazuh-manager
sleep 10
sudo systemctl restart filebeat
sleep 5
sudo systemctl start wazuh-dashboard
sleep 15

echo "== 4/4: Проверка =="
sudo journalctl -u wazuh-dashboard -n 15 --no-pager

echo ""
echo "Готово."
echo "Dashboard:  https://<soc-siem-ip>:443"
echo "User:       admin"
echo "Password:   $NEW_PASSWORD"
echo ""
echo "ВАЖНО: если открываешь через SSH-туннель (vagrant ssh soc_siem -- -L 8443:localhost:443),"
echo "и видишь старую ошибку 500 в браузере — это скорее всего КЕШ браузера."
echo "Открой страницу в режиме инкогнито или сделай жёсткое обновление (Ctrl+Shift+R)."
