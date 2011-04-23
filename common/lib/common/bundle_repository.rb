
# repository_paths should be initialized on Agent or Manager start

class BundleRepository

    class << self
        attr_accessor :repository_path
    end

end
