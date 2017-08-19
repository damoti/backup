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

<dl>
  <dt>POSTGRES_DB</dt>
  <dd><b>REQUIRED</b> One or more database names separated by space or comma, at least one is required. Backups will be performed for each database provided.</dd>

  <dt>POSTGRES_HOST</dt>
  <dd><b>REQUIRED</b> Hostname passed to <code>pg_dump</code> command with <code>-h</code>, usually your PostgreSQL container name.</dd>

  <dt>POSTGRES_PORT</dt>
  <dd>Defaults to <code>5432</code>, passed to <code>pg_dump</code> command with <code>-p</code>.</dd>

  <dt>POSTGRES_USER</dt>
  <dd>Defaults to <code>postgres</code>, passed to <code>pg_dump</code> command with <code>-U</code>.</dd>

  <dt>POSTGRES_EXTRA_OPTS</dt>
  <dd>Defaults to <code>-Z9</code>, any extra options you want passed to <code>pg_dump</code>.</dd>

  <dt>SCHEDULE</dt>
  <dd>Defaults to <code>@hourly</code>, see <a href="http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules">go cron docs</a> for other options.</dd>

  <dt>BACKUP_DIR</dt>
  <dd>Defaults to <code>/backups</code>, path where host backup directory is mounted into the container. This is where the backup script will create hourly/daily/weekly/yearly directories and place the dump files.</dd>

  <dt>BACKUP_KEEP_HOURLY</dt>
  <dd>Defaults to <code>14</code>, number of days worth of hourly backups to keep (to get hourly backups make sure you have <code>SCHEDULE</code> set to <code>@hourly</code> or something more frequent).</dd>

  <dt>BACKUP_KEEP_DAILY</dt>
  <dd>Defaults to <code>60</code>, number of days worth of daily backups to keep. The number of actual backups per day that are kept is determined by <code>BACKUP_DAILY_HOUR_INTERVAL</code>. The default value gives you about 2 months worth of daily backups.</dd>

  <dt>BACKUP_DAILY_HOUR_INTERVAL</dt>
  <dd>Defaults to <code>4</code>, hours apart that daily backups should be made. Default value will produce 6 total backups per day, 4 hours apart. A value of 12 will give you 2 backups per day, a value of 24 will give 1 backup per day.</dd>

  <dt>BACKUP_KEEP_WEEKLY</dt>
  <dd>Defaults to <code>52</code>, number of weeks worth of weekly backups to keep. Due to how the backup script works this will be the last hour of a particular week. The default value gives you a year worth of weekly backups.</dd>

  <dt>BACKUP_KEEP_MONTHLY</dt>
  <dd>Defaults to <code>24</code>, number of months worth of monthly backups to keep. Due to how the backup script works this will be the last hour of the last day of a particular month. The default value gives you two years worth of monthly backups.</dd>
</dl>
