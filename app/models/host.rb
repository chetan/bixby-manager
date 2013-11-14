# == Schema Information
#
# Table name: hosts
#
#  id         :integer          not null, primary key
#  org_id     :integer          not null
#  ip         :string(16)
#  hostname   :string(255)
#  alias      :string(255)
#  desc       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#


class Host < ActiveRecord::Base

  belongs_to :org
  has_one :agent
  acts_as_taggable # adds :tags accessor
  acts_as_paranoid
  has_many :metadata, -> { where("object_type = #{Metadata::Type::HOST}") }, :class_name => :Metadata, :foreign_key => :object_fk_id
  has_and_belongs_to_many :groups, :class_name => :HostGroup, :join_table => "hosts_host_groups"

  multi_tenant :via => :org

  def to_s
    if not self.hostname.blank? then
      self.hostname
    else
      self.ip
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

  def meta
    return @meta if not @meta.nil?

    @meta = {}
    metadata.each do |m|
      @meta[m.key] = m.value
    end

    return @meta
  end

  # Find all hosts which the given user has access to
  # (based on Org)
  #
  # @param [User] user
  #
  # @return [Array<Host>]
  def self.all_for_user(user)
    return nil if user.nil?
    where(:org_id => user.org)
  end
  class << self
    alias_method :for_user, :all_for_user
  end

  # Search for hosts matching the given terms
  #
  # Fields searched for keywords: hostname, ip, alias, desc
  # Search by tag: tag:foo or #foo
  # Search by metadata: foo=bar
  #
  # @param [String] terms
  # @param [User] user to scope for
  #
  # @return [Array<Host>]
  def self.search(terms, user)

    keys = []
    tags = []
    meta = {}

    # parse terms
    terms.split(/\s+/).each do |s|
      if s =~ /^(\w+):(.*?)$/ then
        val = $2
        if $1 =~ /^tags?$/ then
          tags += val.split(/,/)
        end

      elsif s =~ /^#(.*?)$/ then
        tags << $1

      elsif s =~ /^(\w+)=(.*?)$/ then
        meta[$1] = $2

      else
        keys << s
      end
    end

    # find by tag
    if not tags.empty? then
      hosts = Host.for_user(user).tagged_with(tags)
      if hosts.empty? then
        return []
      end

    else
      hosts = Host.for_user(user)
    end

    # filter by metadata
    if not meta.empty? then
      found = []
      hosts.each do |host|
        all_keys_match = true
        meta.keys.each do |key|
          if not(host.meta[key] and host.meta[key].downcase == meta[key].downcase) then
            all_keys_match = false
            break
          end
        end
        found << host if all_keys_match
      end

      hosts = found
    end

    if keys.empty? then
      return hosts
    end

    # filter by keywords
    found = []
    hosts.each do |host|
      all_keys_match = true
      keys.each do |key|
        if not test_key(host, [:hostname, :ip, :alias, :desc], key) then
          all_keys_match = false
          break
        end
      end
      found << host if all_keys_match
    end
    return found

  end


  private

  # Test whether or not the keyword is present in one of the given fields
  #
  # @param [Host] host
  # @param [Array<Symbol>] fields     names of fields to test
  # @param [String] key               keyword
  #
  # @return [Boolean] true if keyword is present in at least one field
  def self.test_key(host, fields, key)

    match = false
    fields.each do |f|
      v = host.send(f)
      if not v.blank? and v.include? key then
        match = true
      end
    end

    return match
  end

end
