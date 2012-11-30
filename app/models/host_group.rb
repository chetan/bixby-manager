# == Schema Information
#
# Table name: host_groups
#
#  id        :integer          not null, primary key
#  org_id    :integer          not null
#  parent_id :integer
#  name      :string(255)      not null
#


class HostGroup < ActiveRecord::Base

  include ActsAsTree
  acts_as_tree :order => "name"

end
