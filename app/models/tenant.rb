# == Schema Information
#
# Table name: tenants
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  password    :string(89)
#  private_key :text
#


class Tenant < ActiveRecord::Base

  has_many :orgs

end
