# ## Schema Information
#
# Table name: `escalation_policies`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `integer`          | `not null, primary key`
# **`org_id`**      | `integer`          | `not null`
# **`name`**        | `string(255)`      |
# **`on_call_id`**  | `integer`          |
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
#
# ### Indexes
#
# * `index_escalation_policies_on_on_call_id`:
#     * **`on_call_id`**
# * `index_escalation_policies_on_org_id`:
#     * **`org_id`**
#

# Just a placeholder for now. Simply contains a link to the current OnCall
# list.
class EscalationPolicy < ActiveRecord::Base

  belongs_to :org
  has_one :on_call
  multi_tenant :via => :org

  # Get the EscalationPolicy rotation for the given Org
  #
  # @param [Org] org
  # @return [EscalationPolicy]
  def self.for_org(org)
    return self.where(:org_id => org.id).first
  end

end
