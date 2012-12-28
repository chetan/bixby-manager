# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  org_id             :integer          not null
#  username           :string(255)      not null
#  crypted_password   :string(255)
#  name               :string(255)
#  email              :string(255)
#  phone              :string(255)
#  persistence_token  :string(255)      not null
#  perishable_token   :string(255)      not null
#  login_count        :integer          default(0), not null
#  failed_login_count :integer          default(0), not null
#  last_request_at    :datetime
#  current_login_at   :datetime
#  last_login_at      :datetime
#  current_login_ip   :string(255)
#  last_login_ip      :string(255)
#


class User < ActiveRecord::Base

  belongs_to :org
  multi_tenant :via => :org

  acts_as_authentic do |config|
    config.login_field :email
    config.crypted_password_field :crypted_password
    config.crypto_provider Authlogic::CryptoProviders::SCrypt
  end

end
