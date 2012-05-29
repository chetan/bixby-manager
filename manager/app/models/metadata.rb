
class Metadata < ActiveRecord::Base

  def self.for(key, val)
    md = Metadata.where(:key => key, :value => val).first
    return md if not md.nil?

    md = Metadata.new
    md.key = key
    md.value = val
    md.save!

    return md
  end

end
