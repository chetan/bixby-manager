
class Manager

    class << self
        attr_accessor :root
    end

end

Manager.root = "/opt/mgr"
