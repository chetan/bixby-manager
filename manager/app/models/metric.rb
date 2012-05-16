
class Metric < ActiveRecord::Base

  belongs_to :resource
  belongs_to :check

end
