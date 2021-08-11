# frozen_string_literal: true

FactoryBot.define do
  factory :dividend do
    ex_dividend_on { Date.today }
    records_on { Date.tomorrow }
    pays_on { Date.today.next_month }
    declares_on { Date.today.last_month }
    sequence(:symbol) { |n| "TST#{n}" }
    dividend { 0.1 }
    adjusted_dividend { 0.1 }

    trait :with_company do
      association :company, factory: :company
    end
  end
end
