# frozen_string_literal: true

require "rails_helper"

RSpec.describe StockSplit, type: :model do
  describe "validation" do
    it "is valid" do
      stock_split = StockSplit.new(
        date: "2021-09-05",
        symbol: "TEST",
        numerator: 2,
        denominator: 1,
      )
      expect(stock_split.valid?).to be true
    end
  end
end
