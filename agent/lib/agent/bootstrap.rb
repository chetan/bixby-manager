
AGENT_ROOT = File.expand_path(File.dirname(__FILE__))
$:.unshift(AGENT_ROOT)

COMMON_ROOT = File.expand_path(File.join(AGENT_ROOT, "../../../common/lib/common"))
if File.exists? COMMON_ROOT then
    # means we're running in a dev environment
    $:.unshift(COMMON_ROOT)
end

if require 'rubygems' then
    require 'bundler'
    Bundler.setup(:default)
end

require 'model/bundle_command'

# load modules
require 'api/modules/inventory'
