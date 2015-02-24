# Read about factories at https://github.com/thoughtbot/factory_girl

require 'factory_girl_rails'
require 'openssl'

module AgentPrivKeyAccessor
  def private_key
    @private_key
  end
end

FactoryGirl.define do

  sequence(:uuid) { |n| "uuid-#{n}" }
  sequence(:pubkey) { |n|  }
  sequence(:username) { |n| "chetan#{n}" }
  sequence(:email_id) { |n| "test#{n}@fw2.net" }
  sequence(:tenant_name) { |n| "foo.org #{n}" }

  factory :agent do
    ip "2.2.2.2"
    port 18000
    uuid { generate(:uuid) }
    is_connected true
    last_seen_at Time.new
    public_key {  }
    association :host

    access_key { Bixby::CryptoUtil.generate_access_key }
    secret_key { Bixby::CryptoUtil.generate_secret_key }

    before(:create) do |agent|
      agent.instance_eval do
        pair = OpenSSL::PKey::RSA.new(File.read(File.join(Rails.root, "test", "support", "keys", "agent_rsa")))
        @private_key = pair.to_s
        self.public_key = pair.public_key.to_s
      end
      agent.extend(AgentPrivKeyAccessor)
    end
  end

  factory :check do
    association :host
    association :agent
    association :command
  end

  factory :metric do
    key "hardware.storage.disk.free"
    tag_hash "foobar"
    association :check
  end

  factory :metric_info do
    association :command
    metric "hardware.storage.disk.free"
    desc "sample metric description"
    label "$mount"
    unit "GB"
  end

  factory :on_call do
    association :org
    name "prod support"
    rotation_period 7
    handoff_day 0
    t = Time.new
    t = Time.local(t.year, t.month, t.day, 12, 0) # noon
    handoff_time t
    association :current_user, :factory => :user
    next_handoff Time.new.next_week.change(:hour => t.hour, :min => t.min)
  end

  factory :host do
    association :org
    ip "127.0.0.1"
    hostname "localhost"
  end

  factory :org do
    association :tenant
    name "default"
  end

  factory :repo do
    name "vendor"
  end

  factory :bundle do
    repo { Repo.first || FactoryGirl.create(:repo) }
    path "test_bundle"
    name "test bundle"
    version "0.0.1"
    desc "my test bundle"
  end

  factory :command do
    repo { Repo.first || FactoryGirl.create(:repo) }
    association :bundle
    name "cat"
    command "cat"
  end


  factory :tenant do
    password SCrypt::Password.create("test").to_s
    private_key OpenSSL::PKey::RSA.new(File.read(File.join(Rails.root, "test", "support", "keys", "tenant_rsa"))).to_s
    name { generate(:tenant_name) }
  end

  factory :user do
    association :org
    username { generate(:username) }
    email { generate(:email_id) }
    password "foobar123"
    password_confirmation "foobar123"
    before(:create) do |user|
      user.skip_confirmation!
    end
  end

  factory :token do
    association :user
    before(:create) do |token|
      token.org_id = token.user.org_id
    end
  end

end
