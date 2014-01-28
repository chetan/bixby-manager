# == Schema Information
#
# Table name: permissions
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  description :string(255)
#


class Permission < ActiveRecord::Base

end
