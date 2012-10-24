
class EscalationPolicy < ActiveRecord::Base

  belongs_to :org
  has_one :on_call

end
