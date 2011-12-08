#!/usr/bin/env ruby

# usage
if ARGV.empty? then
  puts "usage: #{$0} <script>"
  exit
end

# bootstrap agent (assumes we're running in dev env)
require File.join(File.dirname(__FILE__), "../lib/agent")
Bundler.setup(:development, :test)

# find script in ARGV (accounting for spaces)
script = ARGV.shift
while not File.exists? script do
  script += " " + ARGV.shift
end

# look for the bundle root dir and add lib/ to load path
bundledir = File.dirname(script)
while not File.exists? File.join(bundledir, "manifest.json")
  bundledir = File.dirname(bundledir)
end
$: << File.join(bundledir, "lib")

# add helper(s)
require 'awesome_print'

# run the script!
require script

