# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    name { :dividend_aristocrats }
    display_name { "配当貴族" }

    factory :dividend_aristocrats_tag do
      name { :dividend_aristocrats }
      display_name { "配当貴族" }
    end
  end
end
