#!/usr/bin/env ruby -KU

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

AGENT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require AGENT_ROOT + '/app'

App.new.run!
