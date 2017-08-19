# backup

Docker container for backing up PostgreSQL databases.

## docker-compose.yml example

```
version: "3"
services:

  pgdb:
    image: postgres:10

  backup:
    image: damoti/backup
    environment:
      POSTGRES_HOST: pgdb
      POSTGRES_DB: db1, db2
      POSTGRES_PORT: 5432
      POSTGRES_USER: postgres
      POSTGRES_EXTRA_OPTS: '-Z9'
      SCHEDULE: '@hourly'
      BACKUP_DIR: '/backups'
      BACKUP_KEEP_HOURLY: 14
      BACKUP_KEEP_DAILY: 60
      BACKUP_KEEP_WEEKLY: 52
      BACKUP_KEEP_MONTHLY: 24
      BACKUP_DAILY_HOUR_INTERVAL: 4
    volumes:
      - /var/lib/postgresql/backups:/backups
```


<dl>
  <dt>POSTGRES_HOST</dt>
  <dd>**REQUIRED** Hostname passed to `pg_dump` command with `-h`, usually your PostgreSQL container name.</dd>

  <dt>POSTGRES_DB</dt>
  <dd>**REQUIRED** One or more database names separated by space or comma, at least one is required. Backups will be performed for each database provided.</dd>

  <dt>POSTGRES_PORT</dt>
  <dd>Defaults to `5432`, passed to `pg_dump` command with `-p`.</dd>

  <dt>POSTGRES_USER</dt>
  <dd>Defaults to `postgres`, passed to `pg_dump` command with `-U`.</dd>
</dl>
