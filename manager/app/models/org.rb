
class Org < ActiveRecord::Base

  belongs_to :tenant
  has_many :repos
  has_many :users
  has_many :hosts

end
