
class Host < ActiveRecord::Base

  belongs_to :org
  has_one :agent

  def to_s
    if self.alias() then
      self.alias()
    elsif hostname() then
      hostname()
    else
      ip()
    end
  end

end
