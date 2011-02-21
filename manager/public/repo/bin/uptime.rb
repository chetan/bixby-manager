#!/usr/bin/env ruby

# returns JSON array of load averages

require 'rubygems'
require 'json'

ret = `uptime`.strip

# 3:36pm  up 34 days  3:44,  5 users,  load average: 0.42, 0.51, 0.52    GNU
# 15:35  up 34 days,  3:45, 5 users, load averages: 0.43 0.53 0.53       MAC OSX

s = ret.split(",")
s[-1] =~ /load averages: (.*)/
load = $1.split(" ")
print load.to_json
