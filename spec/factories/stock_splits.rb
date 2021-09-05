FactoryBot.define do
  factory :stock_split do
    date { "2021-09-05" }
    symbol { "MyString" }
    numerator { 1.5 }
    denominator { 1.5 }
  end
end
