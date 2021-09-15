# frozen_string_literal: true

require "rails_helper"

RSpec.describe Price, type: :model do
  describe "#for_the_week_of? 引数の Date が属する週の Price かどうかを判定する" do
    context "引数の週に含まれる場合" do
      it "true を返す" do
        price = Price.create!(date: "2021-09-07")
        expect(price.for_the_week_of?("2021-09-05")).to be false # 先週の日曜日
        expect(price.for_the_week_of?("2021-09-06")).to be true # 今週の月曜日
        expect(price.for_the_week_of?("2021-09-12")).to be true # 今週の日曜日
        expect(price.for_the_week_of?("2021-09-13")).to be false # 来週の月曜日
      end
    end
  end
end
