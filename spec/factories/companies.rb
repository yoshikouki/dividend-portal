# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    sequence(:symbol) { |n| "TEST#{n}" }
    sequence(:name) { |n| "The Test#{n} Company" }
    currency { "USD" }
    exchange { "New York Stock Exchange" }
    exchange_short_name { "NYSE" }
    industry { "Beverages—Non-Alcoholic" }
    sector { "Consumer Defensive" }
    country { "US" }
    image { "https://financialmodelingprep.com/image-stock/KO.png" }
    ipo_date { "1919-09-05" }
  end
end
