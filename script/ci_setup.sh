#!/bin/bash

# database.yml
read -d '' yaml <<- EOF
test:
  adapter: sqlite3
  database: tmp/db/test.sqlite3
EOF
echo "$yaml" > config/database.yml

# bixby.yml
read -d '' yaml <<-EOF
test:
  secret_token: "c2bf1135658989e337bff4bc3fc"
  default_tenant: "pixelcop"
  default_tenant_pw: "test"
  redis: "localhost:6379"
  scheduler: "resque"
  metrics: "opentsdb"
  opentsdb:
    host: "localhost"
    port: 4242
  kairosdb:
    host: "localhost"
    telnet_port: 4242
    http_port: 8080
  manager:
    root: "tmp"
    uri:  "http://localhost:3000"
EOF
echo "$yaml" > config/bixby.yml

# mongoid.yml
read -d '' yaml <<-EOF
test:
  sessions:
    default:
      database: bixby_metrics_test
      hosts:
        - localhost:27017
      options:
        consistency: :strong
        # In the test environment we lower the retries and retry interval to
        # low amounts for fast failures.
        max_retries: 1
        retry_interval: 0
EOF
echo "$yaml" > config/mongoid.yml

mkdir -p tmp/db/ tmp/cache tmp/pids log/
RAILS_ENV=test rake db:setup
