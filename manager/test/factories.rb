# Read about factories at https://github.com/thoughtbot/factory_girl

require 'factory_girl_rails'

FactoryGirl.define do

  factory :agent do
    uuid "1234"
    public_key "asdf"
    association :host
  end

  factory :check do
    association :resource
    association :agent
    association :command
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

  factory :resource do
    association :host
  end

  factory :tenant do
  end

  factory :user do
    :org
  end

end
