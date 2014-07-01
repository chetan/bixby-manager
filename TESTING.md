
## Dependencies:
* a running database (mysql, postgres)
* redis
* metrics store (kairos+hbase or mongodb)

## Run:
Each of the following commands should be run in separate terminals (or tabs), including each of the three manager commands.

### manager:
```
$ cd manager
$ zeus start
$ zeus s[erver]
$ sidekiq -c 5 -e development -q schedules
```

### agent:
```
$ cd agent
$ BIXBY_LOG=debug bundle exec bin/bixby-agent --debug
```

### monitoring daemon:
```
$ cd client
$ BIXBY_LOG=debug bin/bixby run mon_d start --ontop
```

## Testing migrations against production database:

* backup:  ``RAILS_ENV=production rake db:backup``
* restore: ``pg_restore --clean --no-owner --dbname bixby_prod bixby-production-20140609.150219.pgsql``
* check:   ``RAILS_ENV=migration rake db:migrate:status``
* test:    ``RAILS_ENV=migration rake db:migrate``
