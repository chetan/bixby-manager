
AGENT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
$:.unshift(AGENT_ROOT) #if not $:.include? AGENT_ROOT

require 'agent/model/bundle_command'

# load modules
require 'common/api/modules/inventory'
