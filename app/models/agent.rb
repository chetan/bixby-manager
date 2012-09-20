
class Agent < ActiveRecord::Base

  belongs_to :host
  acts_as_paranoid

  STATUS_NEW      = 0
  STATUS_ACTIVE   = 1
  STATUS_INACTIVE = 2

  # validations
  validates_presence_of :port, :uuid, :public_key
  validates_uniqueness_of :uuid, :public_key

  def uri
    "http://#{self.ip}:#{self.port}/"
  end

end
