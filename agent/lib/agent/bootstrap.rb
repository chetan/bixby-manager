
AGENT_ROOT = File.expand_path(File.dirname(__FILE__))
$:.unshift(AGENT_ROOT)

COMMON_ROOT = File.expand_path(File.join(AGENT_ROOT, "../../../common/lib/common"))
if File.exists? COMMON_ROOT then
    # means we're runnin in a dev environment
    $:.unshift(COMMON_ROOT)
end

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require AGENT_ROOT + '/model/bundle_command'
