
AGENT_ROOT = File.expand_path(File.dirname(__FILE__))
$: << AGENT_ROOT

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require AGENT_ROOT + '/model/bundle_command'
