#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require 'sinatra'
require 'json'
require 'curb'

AGENT_ROOT = File.expand_path(File.dirname(__FILE__))

require AGENT_ROOT + '/lib/agent'
require AGENT_ROOT + '/lib/rpc'
require AGENT_ROOT + '/lib/rpc-json'

agent = Agent.new
agent.register_agent()

get '/op/:operation' do
  operation_name = params[:operation]

  operation = agent.get_operation(operation_name)
  if operation == nil
    agent.provision_operation(operation_name)
    operation = agent.get_operation(operation_name)
  end

  if operation != nil
    operation.execute
  else
    "Unknown operation #{params[:operation]}"
  end
end
