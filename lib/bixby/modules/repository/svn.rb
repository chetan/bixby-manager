
module Bixby
class Repository < API

  class SvnRepo < BaseRepo
    def clone
      raise NotImplementedError # TODO implement svn checkout
    end

    def update
      raise NotImplementedError # TODO implement svn update
    end
  end

end
end
