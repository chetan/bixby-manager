
class Metadata < ActiveRecord::Base

  if not Metadata.const_defined? :SOURCES then
    SOURCES = {
      1 => "custom",
      2 => "metric",
      3 => "facter"
    }
  end

  def self.for(key, val, source=1)
    md = Metadata.where(:key => key, :value => val, :source => source).first
    return md if not md.nil?

    source ||= 1

    md = Metadata.new
    md.key = key
    md.value = val
    md.source = source
    md.save!

    return md
  end

  def source_name
    SOURCES[source]
  end

end
