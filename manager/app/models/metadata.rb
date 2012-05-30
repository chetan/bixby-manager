
class Metadata < ActiveRecord::Base

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

end
