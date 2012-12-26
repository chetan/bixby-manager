# == Schema Information
#
# Table name: users
#
#  id       :integer          not null, primary key
#  org_id   :integer          not null
#  username :string(255)      not null
#  password :string(89)
#  name     :string(255)
#  email    :string(255)
#  phone    :string(255)
#


class User < ActiveRecord::Base

  belongs_to :org

  acts_as_authentic do |config|
    config.login_field :email
    config.crypted_password_field :crypted_password
    config.crypto_provider Authlogic::CryptoProviders::SCrypt
  end

end
