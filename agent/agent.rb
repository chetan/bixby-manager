#!/usr/bin/env ruby -KU

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require 'json'

AGENT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require AGENT_ROOT + '/agent'
require AGENT_ROOT + '/app'

App.new.run!
