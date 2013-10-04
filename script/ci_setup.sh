#!/bin/bash

read -d '' yaml <<- EOF
test:
  adapter: sqlite3
  database: tmp/db/test.sqlite3
EOF

echo "$yaml" > config/database.yml
RAILS_ENV=test rake db:setup
