
require 'bundler'

cwd = Dir.pwd
Dir.chdir(File.dirname(__FILE__))
Bundler.setup(:default)
Dir.chdir(cwd)

AGENT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
$:.unshift(AGENT_ROOT) #if not $:.include? AGENT_ROOT

COMMON_ROOT = File.expand_path(File.join(AGENT_ROOT, "../../../common/lib/common"))
if File.exists? COMMON_ROOT then
    # means we're running in a dev environment
    $:.unshift(COMMON_ROOT) if not $:.include? COMMON_ROOT
end

require 'agent/model/bundle_command'

# load modules
require 'common/api/modules/inventory'
