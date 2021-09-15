# frozen_string_literal: true

FactoryBot.define do
  factory :price do
    date { "2021-09-15" }
    open { 1.5 }
    high { 1.5 }
    low { 1.5 }
    close { 1.5 }
    adjusted_close { 1.5 }
    volume { 1.5 }
    unadjusted_volume { 1.5 }
    change { 1.5 }
    change_percent { 1.5 }
    vwap { 1.5 }
    change_over_time { 1.5 }
    symbol { "MyString" }
  end
end
