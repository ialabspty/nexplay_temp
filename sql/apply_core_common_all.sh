#!/usr/bin/env bash
set -euo pipefail

HOST="p3plzcpnl508943.prod.phx3.secureserver.net"
PORT="3306"
USER="openclaw_admin"
PASS="IaLabs25.!"
SQL_FILE="/home/alexander-ortega/.openclaw/workspace/agents/hq/internal/sql/core_common_schema.sql"

DBS=(
  "LogisticsBridge"
  "ServiceBridge"
  "EduBridge"
  "SupplyBridge"
  "BusinessOpsBridge"
  "RetailBridge"
  "ClinicBridge"
)

for DB in "${DBS[@]}"; do
  echo "==> Applying common schema to ${DB}"
  MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "$DB" < "$SQL_FILE"
  echo "==> Done: ${DB}"
  echo
 done

echo "All common schemas applied successfully."
