#!/usr/bin/env ruby -KU

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require File.expand_path(File.join(File.dirname(__FILE__), "../lib/agent"))
require AGENT_ROOT + '/app'

App.new.run!
