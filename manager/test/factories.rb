# Read about factories at https://github.com/thoughtbot/factory_girl

require 'factory_girl_rails'

FactoryGirl.define do

  sequence(:uuid) { |n| "uuid-#{n}" }
  sequence(:pubkey) { |n| "pubkey-#{n}" }

  factory :agent do
    uuid { generate(:uuid) }
    public_key { generate(:pubkey) }
    association :host
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

  factory :command do
    association :repo
  end

  factory :host do
    association :org
  end

  factory :org do
    association :tenant
  end

  factory :repo do
    association :org
  end

  factory :tenant do
    password "foobar"
  end

  factory :user do
    :org
  end

end
