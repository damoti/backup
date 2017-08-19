#!/bin/bash
set -e

if [[ -z $POSTGRES_HOST ]]; then
  echo "You need to set the POSTGRES_HOST environment variable."
  exit 1
fi

if [[ -n $POSTGRES_DB ]]; then
  echo "You need to set the POSTGRES_DB environment variable."
  exit 1
fi

mkdir -p "$BACKUP_DIR/hourly/" "$BACKUP_DIR/daily/" "$BACKUP_DIR/weekly/" "$BACKUP_DIR/monthly/" "$BACKUP_DIR/yearly/"

for DB in ${POSTGRES_DB//,/ }; do
  HFILE="$BACKUP_DIR/hourly/$DB-`date +%Y%m%d-%H%M`.sql.gz"

  echo "dumping ${DB} to $HFILE..."
  pg_dump -f "$HFILE" -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS $DB

  ln -vf "$HFILE" "$BACKUP_DIR/daily/$DB-`date +%Y%m%d`-`expr $(date +%H) / $BACKUP_DAILY_HOUR_INTERVAL + 1`.sql.gz"
  ln -vf "$HFILE" "$BACKUP_DIR/weekly/$DB-`date +%G%V`.sql.gz"
  ln -vf "$HFILE" "$BACKUP_DIR/monthly/$DB-`date +%Y%m`.sql.gz"
  ln -vf "$HFILE" "$BACKUP_DIR/yearly/$DB-`date +%Y`.sql.gz"

  find "$BACKUP_DIR/hourly"  -maxdepth 1 -mtime +$BACKUP_KEEP_HOURLY                  -name "$DB-*.sql*" -exec rm -rf '{}' ';'
  find "$BACKUP_DIR/daily"   -maxdepth 1 -mtime +$BACKUP_KEEP_DAILY                   -name "$DB-*.sql*" -exec rm -rf '{}' ';'
  find "$BACKUP_DIR/weekly"  -maxdepth 1 -mtime +`expr $BACKUP_KEEP_WEEKLY \* 7 + 1`   -name "$DB-*.sql*" -exec rm -rf '{}' ';'
  find "$BACKUP_DIR/monthly" -maxdepth 1 -mtime +`expr $BACKUP_KEEP_MONTHLY \* 31 + 1` -name "$DB-*.sql*" -exec rm -rf '{}' ';'
done
