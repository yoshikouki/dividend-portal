# frozen_string_literal: true

FactoryBot.define do
  factory :report_queue do
    type { "" }
    dividend { nil }
  end

  trait :with_no_dividend_aristocrats_dividend do
    dividend { association :dividend_with_company }
  end
end
