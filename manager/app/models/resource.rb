
class Resource < ActiveRecord::Base

  belongs_to :host
  has_one :check

end
