#!/usr/bin/env ruby -KU

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

$: << File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require 'bixby_agent'
require 'bixby_agent/app'

Bixby::App.new.run!
