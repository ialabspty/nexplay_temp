#!/usr/bin/env bash
set -euo pipefail

HOST="p3plzcpnl508943.prod.phx3.secureserver.net"
PORT="3306"
USER="openclaw_admin"
PASS="IaLabs25.!"

DBS=(
  "hq"
  "LogisticsBridge"
  "ServiceBridge"
  "EduBridge"
  "SupplyBridge"
  "BusinessOpsBridge"
  "RetailBridge"
  "ClinicBridge"
  "openclaw_test"
)

for DB in "${DBS[@]}"; do
  echo "===== ${DB} ====="
  MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "$DB" -e "SHOW TABLES;"
  echo
 done
