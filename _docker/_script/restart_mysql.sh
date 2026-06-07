#!/bin/bash
set -euo pipefail

echo "[SFD] MySQL: Stopping any running instance..."
pkill -f mysqld || true
sleep 3

echo "[SFD] MySQL: Cleaning stale pid..."
rm -f /var/run/mysqld/mysqld.pid

echo "[SFD] MySQL: Starting..."

exec mysqld \
  --innodb_buffer_pool_size="${SF_MYSQL_SETUP_BUFFER_POOL_SIZE:-1G}" \
  --innodb_buffer_pool_instances="${SF_MYSQL_SETUP_BUFFER_POOL_INSTANCES:-8}" \
  --innodb_log_file_size="${SF_MYSQL_SETUP_LOG_SIZE:-512M}" \
  --max_connections="${SF_MYSQL_MAX_CONN:-500}" \
  --innodb_flush_log_at_trx_commit="${SF_MYSQL_FLUSH_TRX_COMMIT:-2}" \
  --innodb_io_capacity="${SF_MYSQL_CAPACITY:-2000}" \
  --table_open_cache="${SF_MYSQL_TABLE_OPEN_CACHE:-4000}" \
  --user=mysql
