
class Tag < ActiveRecord::Base

  def self.for(key, val)
    tag = Tag.where(:key => key, :value => val).first
    return tag if not tag.nil?

    tag = Tag.new
    tag.key = key
    tag.value = val
    tag.save!

    return tag
  end

end
