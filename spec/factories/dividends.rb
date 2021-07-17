# frozen_string_literal: true

FactoryBot.define do
  factory :dividend do
    ex_dividend_on { Date.today }
    records_on { Date.at(1.day.since) }
    pays_on { Date.at(1.week.since) }
    declares_on { Date.at(1.month.ago) }
    symbol { "TST" }
    dividend { 0.1 }
    adjusted_dividend { 0.1 }
  end
end
