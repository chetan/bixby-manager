
class Metric < ActiveRecord::Base

  belongs_to :resource
  belongs_to :check

  # Find an existing Metric or return a new instance
  #
  # @param [Check] check
  # @param [String] key
  # @param [Hash] metadata
  # @return [Metric]
  def self.for(check, key, metadata)

    hash = hash_metadata(metadata)
    m = Metric.first(:conditions => {:check_id => check.id, :key => key, :tag_hash => hash})
    if not m.blank? then
      return m
    end

    m = Metric.new
    m.check = check
    m.resource = check.resource
    m.key = key
    m.tag_hash = hash

    return m

  end


  private

  def self.hash_metadata(metadata)
    key = []
    metadata.keys.each { |k| key << k << metadata[k] }
    return Digest::MD5.new.hexdigest(key.join("_"))
  end


end
