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

end
