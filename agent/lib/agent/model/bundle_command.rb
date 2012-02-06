
require "common/api/json_request"
require "common/api/json_response"
require "common/api/modules/provisioning"

require "agent/model/bundle_util"

require "digest"
require "fileutils"

class BundleCommand

  include BundleUtil

  def initialize
    @agent = Agent.create
  end

end

