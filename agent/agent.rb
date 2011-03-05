#!/usr/bin/env ruby -KU

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require 'json'

AGENT_ROOT = File.expand_path(File.dirname(__FILE__))

require AGENT_ROOT + '/lib/agent'
require AGENT_ROOT + '/lib/app'

App.new.run!
