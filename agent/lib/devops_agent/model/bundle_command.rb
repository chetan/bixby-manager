
require "devops_agent/model/bundle_util"

require "digest"
require "fileutils"

class BundleCommand

  include BundleUtil

  def initialize
    @agent = Agent.create
  end


  # retrieve all loaded subclasses of this classs
  #
  # @return [Array<Class>] List of subclasses
  def self.subclasses
    @subclasses
  end


  private

  def self.inherited(subclass)
    if superclass.respond_to? :inherited
      superclass.inherited(subclass)
    end
    @subclasses ||= []
    @subclasses << subclass
  end

end

