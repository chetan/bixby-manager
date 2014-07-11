
# Disable the mongoid features of `bullet`
# (keeps causing startup issues due to load order?)

module Bullet
  def self.mongoid?
    false
  end
end
