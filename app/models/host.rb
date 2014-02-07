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

  # basic info metadata keys
  BASIC_INFO = %w(architecture fqdn ipaddress ec2_public_ipv4 hostname kernel
                  kernelrelease memsize timezone uptime operatingsystem
                  lsbdistdescription)

  def to_s
    if not self.hostname.blank? then
      self.hostname
    else
      self.ip
    end
  end

  # Get basic metadata for the host
  #
  # @return [Hash] key/value pairs
  def info
    info = {}
    lookup = meta
    BASIC_INFO.each{ |k| info[k] = lookup[k].value if lookup.include?(k) }
    return info
  end

  # Get a lookup table of metadata key/value pairs
  #
  # @return [Hash] metadata key/value pairs
  def meta
    meta = {}
    metadata.each do |m|
      meta[m.key] = m
    end
    return meta
  end

  # Add new metadata to this host
  #
  # @param [String] key
  # @param [String] value
  # @param [Fixnum] source           (optional, default: FACTER)
  def add_metadata(key, value, source=Metadata::Source::FACTER)
    metadata << Metadata.new(:key => key, :value => value, :source => source,
                             :object_type => Metadata::Type::HOST, :object_fk_id => id)
    nil
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
        host_meta = host.meta
        all_keys_match = true
        meta.keys.each do |key|
          if not(host_meta[key] and host_meta[key].value.downcase == meta[key].downcase) then
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

  # Get an alpha-sorted list of all tags used for Hosts owned by the given user
  #
  # @param [User] user
  #
  # @return [Array<String>] tags
  def self.all_tags(user)
    # ActsAsTaggableOn::Tagging.where(:taggable_type => "Host").includes(:tag).map{ |t| t.tag.name }.sort
    for_user(user).tag_counts_on(:tags).map{ |t| t.name }.sort
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
