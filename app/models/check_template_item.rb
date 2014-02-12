# == Schema Information
#
# Table name: check_template_items
#
#  id                :integer          not null, primary key
#  check_template_id :integer          not null
#  command_id        :integer          not null
#  args              :text
#


class CheckTemplateItem < ActiveRecord::Base
  belongs_to :check_template
  has_one :command
end
