# == Schema Information
#
# Table name: escalation_policies
#
#  id         :integer          not null, primary key
#  org_id     :integer          not null
#  name       :string(255)
#  on_call_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class EscalationPolicy < ActiveRecord::Base

  belongs_to :org
  has_one :on_call
  multi_tenant :via => :org

  # Get the EscalationPolicy rotation for the given Org
  #
  # @param [Org] org
  # @return [EscalationPolicy]
  def self.for_org(org)
    return self.first(:conditions => {:org_id => org.id})
  end

end
