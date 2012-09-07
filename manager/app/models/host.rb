
class Host < ActiveRecord::Base

  belongs_to :org
  has_one :agent
  acts_as_taggable # adds :tags accessor
  has_and_belongs_to_many :metadata, :class_name => :Metadata, :join_table => "hosts_metadata"
  has_and_belongs_to_many :groups, :class_name => :HostGroup, :join_table => "hosts_host_groups"

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

  def self.search(terms)

    keys = []
    tags = []

    terms.split(/\s+/).each do |s|
      if s =~ /^(\w+):(.*?)$/ then
        if $1 =~ /^tags?$/ then
          tags += $2.split(/,/)
        end
      else
        keys << s
      end
    end

    if not tags.blank? then
      hosts = Host.tagged_with(tags)
      if hosts.empty? then
        return []
      end
    else
      hosts = Host.all # FIXME use keyword search?
    end

    if keys.empty? then
      return hosts
    end

    # further filter by keywords
    found = []
    hosts.each do |host|
      all_keys_match = true
      keys.each do |key|
        if not (host.hostname.downcase.include? key or
           host.alias.downcase.include? key or
           host.desc.downcase.include? key) then

            all_keys_match = false
        end
      end
      found << host if all_keys_match
    end
    return found

  end

end
