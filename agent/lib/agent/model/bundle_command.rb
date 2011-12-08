
require "api/json_request"
require "api/json_response"
require "api/modules/provisioning"
require "model/bundle_util"

require "digest"
require "fileutils"

class BundleCommand

  include BundleUtil

  def initialize
    @agent = Agent.create
  end

end

