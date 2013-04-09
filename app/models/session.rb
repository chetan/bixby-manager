
class Session < ActiveRecord::Base
  def self.sweep!(time = 2.weeks)
    raise "time must be of type Fixnum" if not time.kind_of? Fixnum
    delete_all ["updated_at < ?", time.ago]
  end
end
