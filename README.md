# backup

Docker container for backing up PostgreSQL 10.0 databases.

Hourly, daily, weekly, monthly and yearly backups are kept in separate directories and each have customizable rotation schedules.

Uses [go-cron](https://github.com/odise/go-cron) for scheduling backups.

## `docker-compose.yml` Example

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

## Environment Variables

Variable     | Default    | Description
-------------|------------|------------
POSTGRES_DB  |            | **required** One or more database names separated by space or comma, at least one is required. Backups will be performed for each database provided.
POSTGRES_HOST|            | **required** Hostname passed to `pg_dump` command with `-h`.
POSTGRES_PORT| `5432`     | Port number passed to `pg_dump` command with `-p`.
POSTGRES_USER| `postgres` | User name passed to `pg_dump` command with `-U`.
POSTGRES_EXTRA_OPTS| `-Z9`| Any extra options you want passed to `pg_dump`.
SCHEDULE     | `@hourly`  | When to run the cron job, see [go cron docs](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules) for other options.
BACKUP_DIR   | `/backups` | Path where host backup directory is mounted into the container. This is where the backup script will create hourly/daily/weekly/yearly directories and place the dump files inside the container.
BACKUP_KEEP_HOURLY| `14`  | Number of days worth of hourly backups to keep (to get hourly backups make sure you have SCHEDULE set to `@hourly` or something more frequent).
BACKUP_KEEP_DAILY| `60`   | Number of days worth of daily backups to keep. The number of actual backups per day that are kept is determined by BACKUP_DAILY_HOUR_INTERVAL. The default value gives you about 2 months worth of daily backups.
BACKUP_DAILY_HOUR_INTERVAL|`4`| Hours apart that daily backups should be made. Default value will produce 6 total backups per day, 4 hours apart. A value of 12 will give you 2 backups per day, a value of 24 will give 1 backup per day.
BACKUP_KEEP_WEEKLY| `52`  | Number of weeks worth of weekly backups to keep. Due to how the backup script works this will be the last hour of a particular week. The default value gives you a year worth of weekly backups.
BACKUP_KEEP_MONTHLY| `24` | Number of months worth of monthly backups to keep. Due to how the backup script works this will be the last hour of the last day of a particular month. The default value gives you two years worth of monthly backups.
