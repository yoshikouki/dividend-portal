# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    name { :test_tag }
    display_name { "テスト用タグ" }

    factory :dividend_aristocrats_tag do
      name { :dividend_aristocrats }
      display_name { "配当貴族" }
    end
  end
end
