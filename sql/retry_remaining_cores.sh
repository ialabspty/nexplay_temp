#!/usr/bin/env bash
set -euo pipefail

HOST="p3plzcpnl508943.prod.phx3.secureserver.net"
PORT="3306"
USER="openclaw_admin"
PASS="IaLabs25.!"
COMMON_SQL="/home/alexander-ortega/.openclaw/workspace/agents/hq/internal/sql/core_common_schema.sql"

DBS=(
  "RetailBridge"
  "ClinicBridge"
  "openclaw_test"
)

for DB in "${DBS[@]}"; do
  echo "==> Checking access: ${DB}"
  MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "$DB" -e "SELECT DATABASE() AS db;"

  if [[ "$DB" == "openclaw_test" ]]; then
    echo "==> Skipping common core schema for ${DB}; test schema will be applied separately"
  else
    echo "==> Applying common schema to ${DB}"
    MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "$DB" < "$COMMON_SQL"
    echo "==> Done: ${DB}"
  fi
  echo
 done

echo "Remaining databases processed successfully."
