# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  org_id                 :integer          not null
#  username               :string(255)      not null
#  encrypted_password     :string(255)
#  name                   :string(255)
#  email                  :string(255)
#  phone                  :string(255)
#  sign_in_count          :integer          default(0), not null
#  failed_attempts        :integer          default(0), not null
#  last_request_at        :datetime
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  password_salt          :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_token         :string(255)
#  remember_created_at    :datetime
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#

# temp workaround for load order issues
# user model now gets loaded at various different points in the process
require "rails_ext/multi_tenant"
require "devise"
require "devise/orm/active_record"

class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable, :encryptable,
         :authentication_keys => [ :username ]

  has_and_belongs_to_many :roles, :join_table => :users_roles
  has_many :user_permissions, -> { includes :permissions }
  # has_many :permissions, :through => :user_permissions

  belongs_to :org
  multi_tenant :via => :org

  def self.find_for_authentication(tainted_conditions)
    opts = devise_parameter_filter.filter(tainted_conditions)
    find_by_username_or_email(opts[:username])
  end

  def self.find_by_username_or_email(login)
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
        p.resource == object.class &&
          (p.resource_id.nil? || p.resource_id == object.id)
      }.nil?
  end
  alias_method :can, :can?

  def cant?(permission, object=nil)
    !can?(permission, object)
  end
  alias_method :cant, :cant?

end
