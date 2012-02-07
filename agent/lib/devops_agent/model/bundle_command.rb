
require "devops_agent/model/bundle_util"

require "digest"
require "fileutils"

class BundleCommand

  include BundleUtil

  def initialize
    @agent = Agent.create
  end

end

