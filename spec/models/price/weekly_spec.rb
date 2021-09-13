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

  describe ".calculate_from_daily_prices" do
    context "Price::History クラスが渡された場合" do
      let!(:raw_prices) do
        [{ date: "2021-09-10", open: 56.01, high: 56.13, low: 55.52, close: 55.61, adjusted_close: 55.61, volume: 10_301_372.0, unadjusted_volume: 10_301_372.0,
           change: -0.4, change_percent: -0.714, vwap: 55.75333, label: "September 10, 21", change_over_time: -0.00714, symbol: "KO" },
         { date: "2021-09-07", open: 56.6, high: 56.69, low: 55.51, close: 55.67, adjusted_close: 55.67, volume: 15_349_798.0, unadjusted_volume: 15_349_798.0,
           change: -0.93, change_percent: -1.643, vwap: 55.95667, label: "September 07, 21", change_over_time: -0.01643, symbol: "KO" },
         { date: "2021-09-03", open: 56.46, high: 56.77, low: 56.25, close: 56.73, adjusted_close: 56.73, volume: 9_578_609.0, unadjusted_volume: 9_578_609.0,
           change: 0.27, change_percent: 0.478, vwap: 56.58333, label: "September 03, 21", change_over_time: 0.00478, symbol: "KO" },
         { date: "2021-09-01", open: 56.38, high: 56.8, low: 56.28, close: 56.69, adjusted_close: 56.69, volume: 9_404_637.0, unadjusted_volume: 9_404_637.0,
           change: 0.31, change_percent: 0.55, vwap: 56.59, label: "September 01, 21", change_over_time: 0.0055, symbol: "KO" }]
      end
      let!(:prices) { Price::History.new(prices: raw_prices) }

      it "週足で計算し直した Price::Weekly インスタンスを返す" do
        weekly_prices = Price::Weekly.calculate_from_daily_prices(prices)
        expected = Price::Weekly.new
        expected_hash = [
          { date: "2021-09-07", open: 56.6, high: 56.69, low: 55.51, close: 55.67, adjusted_close: 55.67, volume: 15_349_798.0, unadjusted_volume: 15_349_798.0,
            change: -0.93, change_percent: -1.643, vwap: 55.95667, label: "September 07, 21", change_over_time: -0.01643, symbol: "KO" },
          { date: "2021-09-01", open: 56.38, high: 56.8, low: 56.28, close: 56.69, adjusted_close: 56.69, volume: 9_404_637.0, unadjusted_volume: 9_404_637.0,
            change: 0.31, change_percent: 0.55, vwap: 56.59, label: "September 01, 21", change_over_time: 0.0055, symbol: "KO" },
        ]
        expect(weekly_prices).to eq(expected)
        expect(weekly_prices.all).to eq(expected_hash)
      end
    end
  end
end
