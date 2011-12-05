
class Host < ActiveRecord::Base

  belongs_to :org
  has_one :agent

end
