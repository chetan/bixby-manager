# == Schema Information
#
# Table name: check_templates
#
#  id     :integer          not null, primary key
#  org_id :integer
#  name   :string(255)      not null
#  mode   :integer          not null
#  tags   :string(255)
#


class CheckTemplate < ActiveRecord::Base
  has_many :check_template_items
  belongs_to :org
  multi_tenant :via => :org
end
