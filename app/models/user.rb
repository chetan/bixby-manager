# ## Schema Information
#
# Table name: `users`
#
# ### Columns
#
# Name                             | Type               | Attributes
# -------------------------------- | ------------------ | ---------------------------
# **`id`**                         | `integer`          | `not null, primary key`
# **`org_id`**                     | `integer`          | `not null`
# **`username`**                   | `string(255)`      | `not null`
# **`encrypted_password`**         | `string(255)`      |
# **`name`**                       | `string(255)`      |
# **`email`**                      | `string(255)`      |
# **`phone`**                      | `string(255)`      |
# **`sign_in_count`**              | `integer`          | `default("0"), not null`
# **`failed_attempts`**            | `integer`          | `default("0"), not null`
# **`last_request_at`**            | `datetime`         |
# **`current_sign_in_at`**         | `datetime`         |
# **`last_sign_in_at`**            | `datetime`         |
# **`current_sign_in_ip`**         | `string(255)`      |
# **`last_sign_in_ip`**            | `string(255)`      |
# **`password_salt`**              | `string(255)`      |
# **`confirmation_token`**         | `string(255)`      |
# **`confirmed_at`**               | `datetime`         |
# **`confirmation_sent_at`**       | `datetime`         |
# **`unconfirmed_email`**          | `string(255)`      |
# **`reset_password_token`**       | `string(255)`      |
# **`reset_password_sent_at`**     | `datetime`         |
# **`remember_token`**             | `string(255)`      |
# **`remember_created_at`**        | `datetime`         |
# **`unlock_token`**               | `string(255)`      |
# **`locked_at`**                  | `datetime`         |
# **`created_at`**                 | `datetime`         |
# **`updated_at`**                 | `datetime`         |
# **`encrypted_otp_secret`**       | `string(255)`      |
# **`encrypted_otp_secret_iv`**    | `string(255)`      |
# **`encrypted_otp_secret_salt`**  | `string(255)`      |
# **`otp_required_for_login`**     | `boolean`          |
# **`otp_tmp_id`**                 | `string(255)`      |
# **`invite_token`**               | `string(255)`      |
# **`invite_created_at`**          | `datetime`         |
# **`invite_sent_at`**             | `datetime`         |
# **`invite_accepted_at`**         | `datetime`         |
# **`invited_by_id`**              | `integer`          |
#
# ### Indexes
#
# * `fk_users_orgs1`:
#     * **`org_id`**
# * `index_users_on_confirmation_token` (_unique_):
#     * **`confirmation_token`**
# * `index_users_on_last_request_at`:
#     * **`last_request_at`**
# * `index_users_on_reset_password_token` (_unique_):
#     * **`reset_password_token`**
# * `index_users_on_unlock_token` (_unique_):
#     * **`unlock_token`**
#

# temp workaround for load order issues
# user model now gets loaded at various different points in the process
require "rails_ext/multi_tenant"
require "archie/model"
require "archie/otp"

class User < ActiveRecord::Base

  include Archie::Model
  include Archie::OTP::Model

  has_and_belongs_to_many :roles, -> { includes :role_permissions }, :join_table => :users_roles
  has_many :user_permissions, -> { includes :permissions }
  # has_many :permissions, :through => :user_permissions

  belongs_to :org, -> { includes :tenant }
  multi_tenant :via => :org

  def self.find_by_username_or_email(login)
    return nil if login.blank?
    if login.include? "@" then
      where("email = ? OR username = ?", login, login).first
    else
      where("username = ?", login).first
    end
  end

  # Set of all permissions, either directly assigned or via an active role assignment
  #
  # @return [Array<UserPermission> + Array<RolePermission>]
  def permissions
    @permissions ||= (self.user_permissions.to_a + self.roles.map{ |r| r.role_permissions.to_a }).flatten
  end

  # Test if this user has the given permission. Optionally tests access to the given object.
  #
  # @param [String] permission
  # @param [Object] object            (optional, default: nil)
  #
  # @return [Boolean] true if user has the given access
  def can?(permission, object=nil)

    if object.nil? then
      # test for an object-less permission
      # ex: impersonate_users
      return !self.permissions.find{ |p| p.resource.nil? && p.name == permission.to_s }.nil?
    end

    # match the resource type & optionally the instance id
    return !self.permissions.find{ |p|
        p.resource == object.class.name &&
          (p.resource_id.nil? || p.resource_id == object.id)
      }.nil?
  end
  alias_method :can, :can?

  def cant?(permission, object=nil)
    !can?(permission, object)
  end
  alias_method :cant, :cant?

  def display_name
    self.name || self.username
  end

  def email_address
    name = self.display_name
    if name.blank? then
      self.email
    else
      "#{name} <#{self.email}>"
    end
  end

end
