#!/bin/bash

# database.yml
read -d '' yaml <<-EOF
test:
  adapter: sqlite3
  database: tmp/db/test.sqlite3
EOF
echo "$yaml" > config/database.yml

# secrets.yml
read -d '' yaml <<-EOF
test:
  secret_key_base: "c2bf1135658989e337bff4bc3fc"
EOF
echo "$yaml" > config/secrets.yml

# bixby.yml
read -d '' yaml <<-EOF
test:
  secret_token: "secret"
  archie_secret_key: "secret"
  archie_pepper: "secret"
  otp_secret_encryption_key: "secret"
  mailer_from: "test@example.com"
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
        max_retries: 1
        retry_interval: 0
EOF
echo "$yaml" > config/mongoid.yml

mkdir -p tmp/db/ tmp/cache tmp/pids log/
RAILS_ENV=test bundle exec rake db:create db:schema:load

# setup git config
git config --global user.email "jdoe@example.com"
git config --global user.name "John Doe"
