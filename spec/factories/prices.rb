# frozen_string_literal: true

FactoryBot.define do
  factory :price do
    date { "2021-09-15" }
    open { 10 }
    high { 20 }
    low { 1 }
    close { 20 }
    adjusted_close { 20 }
    volume { 100 }
    unadjusted_volume { 100 }
    change { 10 }
    change_percent { 100 }
    vwap { 15 }
    change_over_time { 100 }
    symbol { "TEST" }
  end
end
