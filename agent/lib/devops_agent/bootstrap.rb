
AGENT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
$:.unshift(AGENT_ROOT) #if not $:.include? AGENT_ROOT

require 'devops_agent/model/bundle_command'
