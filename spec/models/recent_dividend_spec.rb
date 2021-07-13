# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecentDividend, type: :model do
  valid_params = {
    ex_dividend_on: "2020-08-07",
    records_on: "2020-08-10",
    pays_on: "2020-09-10",
    declares_on: "2020-07-28",
    symbol: "IBM",
    dividend: 1.63,
    adjusted_dividend: 1.63,
  }

  describe "validates" do
    it "正しい" do
      dividend = RecentDividend.new(valid_params)
      expect(dividend.valid?).to be true
    end
  end
end
