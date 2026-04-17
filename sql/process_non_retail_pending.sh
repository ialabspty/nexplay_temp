#!/usr/bin/env bash
set -euo pipefail

HOST="p3plzcpnl508943.prod.phx3.secureserver.net"
PORT="3306"
USER="openclaw_admin"
PASS="IaLabs25.!"
COMMON_SQL="/home/alexander-ortega/.openclaw/workspace/agents/hq/internal/sql/core_common_schema.sql"

# ClinicBridge
DB="ClinicBridge"
echo "==> Checking access: ${DB}"
MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "$DB" -e "SELECT DATABASE() AS db;"
echo "==> Applying common schema to ${DB}"
MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "$DB" < "$COMMON_SQL"
echo "==> Done: ${DB}"
echo

# openclaw_test access check only for now
echo "==> Checking access: openclaw_test"
MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "openclaw_test" -e "SELECT DATABASE() AS db;"
echo "==> openclaw_test reachable; test schema will be applied separately"

echo "Non-Retail pending databases processed successfully."
