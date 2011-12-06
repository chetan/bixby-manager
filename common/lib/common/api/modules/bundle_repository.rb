
# path should be initialized on Agent or Manager start

class BundleRepository < BaseModule

  class << self
    attr_accessor :path
  end

end
