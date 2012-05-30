
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

  def info
    info = {}
    wanted = %w(architecture fqdn ipaddress ec2_public_ipv4 hostname kernel kernelrelease memsize timezone uptime operatingsystem lsbdistdescription)
    self.metadata.each do |m|
      if wanted.include? m.key then
        info[m.key] = m.value
      end
    end

    return info
  end

end
