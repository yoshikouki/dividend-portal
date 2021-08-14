# frozen_string_literal: true

FactoryBot.define do
  factory :dividend do
    ex_dividend_on { Date.today }
    records_on { Date.tomorrow }
    pays_on { Date.today.next_month }
    declares_on { Date.today.last_month }
    sequence(:symbol) { |n| "TEST#{n}" }
    dividend { 0.1 }
    adjusted_dividend { 0.1 }

    trait :with_company do
      association :company, factory: :company
    end

    trait :with_dividend_aristocrats_company do
      association :company, factory: :dividend_aristocrats_company
    end
  end
end
