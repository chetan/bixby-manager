
COMMON_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../../../common/lib/common"))
if File.exists? COMMON_ROOT then
    # means we're runnin in a dev environment
    $:.unshift(COMMON_ROOT)
end

require 'manager'
require 'bundle_repository'
require 'api/modules/base_module'

BundleRepository.repository_path = File.join(Manager.root, "/repo")
BaseModule.manager_uri = "http://localhost:3000/"
