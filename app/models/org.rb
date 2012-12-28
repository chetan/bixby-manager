# == Schema Information
#
# Table name: orgs
#
#  id        :integer          not null, primary key
#  tenant_id :integer
#  name      :string(255)
#


class Org < ActiveRecord::Base

  belongs_to :tenant
  has_many :repos
  has_many :users
  has_many :hosts

  multi_tenant

end
