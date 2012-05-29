
class Host < ActiveRecord::Base

  belongs_to :org
  has_one :agent
  acts_as_taggable # adds :tags accessor
  has_and_belongs_to_many :metadata, :class_name => :Metadata, :join_table => "hosts_metadata"

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
