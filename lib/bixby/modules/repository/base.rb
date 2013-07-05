
module Bixby
class Repository < API

  class BaseRepo < API
    attr_accessor :repo
    def initialize(repo)
      @repo = repo
    end
    def clone
      raise NotImplementedError
    end
    def update
      raise NotImplementedError
    end
  end

end
end
