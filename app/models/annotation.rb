# == Schema Information
#
# Table name: annotations
#
#  id         :integer          not null, primary key
#  host_id    :integer
#  name       :string(255)      not null
#  detail     :text
#  created_at :datetime
#


class Annotation < ActiveRecord::Base

  belongs_to :host
  acts_as_taggable # adds :tags accessor

end
