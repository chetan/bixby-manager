#!/usr/bin/env bash

set -e

aptitude -y install build-essential ruby rubygems curl libcurl4-openssl-dev
tar -xzf bixby-agent.tar.gz
cd bixby/
bin/bundle install --deployment --local --without development test
cd ..
mv bixby /opt/
cd /opt/bixby/
