
require "devops_common/api/json_request"
require "devops_common/api/json_response"
require "devops_common/api/modules/provisioning"

require "devops_agent/model/bundle_util"

require "digest"
require "fileutils"

class BundleCommand

  include BundleUtil

  def initialize
    @agent = Agent.create
  end

end

