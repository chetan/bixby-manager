#!/bin/bash

read -d '' yaml <<- EOF
test:
  adapter: sqlite3
  database: tmp/db/test.sqlite3
EOF

echo "$yaml" > config/database.yml
mkdir -p tmp/db/ tmp/cache tmp/pids log/
RAILS_ENV=test rake db:setup
