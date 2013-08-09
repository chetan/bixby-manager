# == Schema Information
#
# Table name: metadata
#
#  id     :integer          not null, primary key
#  key    :string(255)      not null
#  value  :text             not null
#  source :integer          default(1), not null
#


class Metadata < ActiveRecord::Base

  if not Metadata.const_defined? :SOURCES then
    SOURCES = {
      1 => "custom",
      2 => "metric",
      3 => "facter"
    }
  end

  def self.for(key, val, source=1)
    val = val.nil? ? val : val.to_s
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
