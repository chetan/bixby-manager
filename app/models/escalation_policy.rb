
class EscalationPolicy < ActiveRecord::Base

  belongs_to :org
  has_one :on_call

  # Get the EscalationPolicy rotation for the given Org
  #
  # @param [Org] org
  # @return [EscalationPolicy]
  def self.for_org(org)
    return self.first(:conditions => {:org_id => org.id})
  end

end
