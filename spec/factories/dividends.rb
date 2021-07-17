# frozen_string_literal: true

FactoryBot.define do
  factory :dividend do
    ex_dividend_on { Date.today }
    records_on { Date.tomorrow }
    pays_on { Date.today.next_month }
    declares_on { Date.today.last_month }
    symbol { "TST" }
    dividend { 0.1 }
    adjusted_dividend { 0.1 }
  end
end
