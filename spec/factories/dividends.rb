# frozen_string_literal: true

FactoryBot.define do
  factory :dividend do
    ex_dividend_date { Date.today }
    records_on { Date.tomorrow }
    pays_on { Date.today.next_month }
    declares_on { Date.today.last_month }
    sequence(:symbol) { |n| "TEST#{n}" }
    dividend { 0.1 }
    adjusted_dividend { 0.1 }
    company { nil }

    trait :with_company do
      association :company, factory: :company
    end
    factory :dividend_with_company, traits: [:with_company]

    trait :with_dividend_aristocrats_company do
      association :company, factory: :dividend_aristocrats_company
    end
    factory :dividend_with_dividend_aristocrats_company, traits: [:with_dividend_aristocrats_company]
  end
end
