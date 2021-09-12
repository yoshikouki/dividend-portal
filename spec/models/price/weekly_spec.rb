# frozen_string_literal: true

require "rails_helper"

describe "Price::Weekly" do
  describe ".dividend_aristocrats_in_order_of_change_percent" do
    before do
      Company::DividendAristocrat.setup
    end

    it "true を返す" do
      VCR.use_cassette("models/price/weekly/dividend_aristocrats_in_order_of_change_percent") do
        weekly_prices = Price::Weekly.dividend_aristocrats_in_order_of_change_percent
        expected = Price::Weekly.new
        expect(weekly_prices).to eq(expected)
      end
    end
  end
end
