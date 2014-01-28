# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  tenant_id   :integer
#  name        :string(255)      not null
#  description :string(255)
#


class Role < ActiveRecord::Base

  has_many :role_permissions, -> { includes :permission }
  # has_many :permissions, :through => :role_permissions

  has_and_belongs_to_many :users, :join_table => :users_roles

end
