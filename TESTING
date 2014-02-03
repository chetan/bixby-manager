
Dependencies:
* a running database (mysql, postgres)
* redis
* metrics store (kairos+hbase or mongodb)


Run in separate terminals:

manager:
$ zeus start
$ zeus s[erver]
$ sidekiq -c 5 -e development -q "*,schedules"

to generate monitoring/metrics data:
(from the client dir)
$ BIXBY_LOG=debug bin/bixby run mon_d start --ontop

to run the agent:
$ BIXBY_LOG=debug bundle exec bin/bixby-agent --debug
