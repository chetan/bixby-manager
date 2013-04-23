# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  session_id :string(255)      not null
#  data       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class Session < ActiveRecord::Base
  def self.sweep!(time = 2.weeks)
    raise "time must be of type Fixnum" if not time.kind_of? Fixnum
    delete_all ["updated_at < ?", time.ago]
  end
end
