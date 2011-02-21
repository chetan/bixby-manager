#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'
require 'json'
require 'curb'

require './rpc-json'

class Agent
  attr_accessor :manager_ip, :manager_port
  attr_accessor :agent_uuid, :agent_ip, :agent_root

  def initialize
    @manager_ip = '192.168.44.99'
    @manager_port = 3000
    
    @agent_uuid = 12345
    @agent_ip = '192.168.44.109'
    @agent_root = '/opt/devops/'
  end

  def register_agent
    puts "http://#{manager_ip}:#{manager_port}/agent/register?ip=#{agent_ip}&uuid=#{agent_uuid}"
    puts Curl::Easy.http_get("http://#{manager_ip}:#{manager_port}/agent/register?ip=#{agent_ip}&uuid=#{agent_uuid}").body_str
  end

  def operation_dir(operation_name)
    agent_root + operation_name
  end

  def operation_script(operation_name)
    operation_dir(operation_name) + '/' + operation_name + '.rb'
  end

  def get_operation(operation_name)
    operation_script = operation_script(operation_name)
    if File.exist?(operation_script)
      return Operation.new(operation_script(operation_name))
    else
      return nil
    end
  end

  def provision_operation(operation_name)
    result = Curl::Easy.http_get("http://#{manager_ip}:#{manager_port}/repo/fetch?name=#{operation_name}").body_str
    url = JSON.parse(result)['files'].first

    script = Curl::Easy.http_get(url).body_str

    operation_dir = operation_dir(operation_name)
    operation_script = operation_script(operation_name)

    FileUtils.mkdir_p(operation_dir)
    File.open(operation_script, 'w') {|f| f.write(script)}
    `chmod 755 #{operation_script}`
  end

  class Operation
    attr_accessor :operation_script
    
    def initialize(script)
      @operation_script = script
    end
    
    def execute
      data = `sh -c #{operation_script}`
      returnCode = $?

      return Response.new(returnCode, data).to_json
    end
  end

end

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
