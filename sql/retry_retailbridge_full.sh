#!/usr/bin/env bash
set -euo pipefail
HOST="p3plzcpnl508943.prod.phx3.secureserver.net"
PORT="3306"
USER="openclaw_admin"
PASS="IaLabs25.!"
COMMON_SQL="/home/alexander-ortega/.openclaw/workspace/agents/hq/internal/sql/core_common_schema.sql"
SPECIFIC_SQL="/home/alexander-ortega/.openclaw/workspace/agents/hq/internal/sql/retailbridge_schema.sql"

MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "RetailBridge" -e "SELECT DATABASE() AS db;"
MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "RetailBridge" < "$COMMON_SQL"
MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "RetailBridge" < "$SPECIFIC_SQL"
MYSQL_PWD="$PASS" mysql -h "$HOST" -P "$PORT" -u "$USER" -D "RetailBridge" -e "SHOW TABLES;"
