#!/usr/bin/env ruby -KU

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

$: << File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require 'devops_agent'
require 'devops_agent/app'

App.new.run!
