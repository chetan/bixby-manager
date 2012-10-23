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

  factory :agent do
    ip "2.2.2.2"
    port = 18000
    uuid { generate(:uuid) }
    public_key {  }
    association :host

    before(:create) do |agent|
      agent.instance_eval do
        pair = OpenSSL::PKey::RSA.generate(2048)
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
    metric "hardware.storage.disk.free"
    desc "sample metric description"
    label "$mount"
    unit "GB"
  end

  factory :on_call do
    name "prod support"
    rotation_period 7
    handoff_day 0
    t = Time.new
    t = Time.local(t.year, t.month, t.day, 12, 0) # noon
    handoff_time t
    association :current_user, :factory => :user
    next_handoff Time.new.next_week.change(:hour => t.hour, :min => t.min)
  end

  factory :metadata do
    key "uptime"
    value "34 days"
    source 3
  end

  factory :command do
    association :repo
    name "foobar"
    bundle "foo"
    command "bar"
  end

  factory :host do
    association :org
  end

  factory :org do
    association :tenant
  end

  factory :repo do
    association :org
    name "repo"
  end

  factory :tenant do
    password "foobar"
    private_key OpenSSL::PKey::RSA.generate(2048).to_s
  end

  factory :user do
    association :org
    username "chetan"
    email "test@fw2.net"
  end

end
