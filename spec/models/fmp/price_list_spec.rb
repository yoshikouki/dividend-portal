# frozen_string_literal: true

require "rails_helper"

describe "Fmp::PriceList" do
  describe ".historical" do
    context "シンボルが一つの場合" do
      it "シンボルの過去の株価をまとめた PriceList を返す" do
        VCR.use_cassette("models/fmp/price_list/historical") do
          price_list = Fmp::PriceList.historical("KO", from: "2021-09-01", to: "2021-09-03")
          expect(price_list).to be_instance_of Fmp::PriceList
          expect(price_list.responses.count).to eq 1
          expect(price_list.list.count).to eq 1
          expect(price_list.flatten.count).to eq 5
        end
      end
    end

    context "シンボルが最大5つまでの複数の場合" do
      it "複数のシンボルに関する過去の株価をまとめた PriceList インスタンスで返す" do
        VCR.use_cassette("models/fmp/price_list/historical_for_multiple_symbols") do
          price_list = Fmp::PriceList.historical(%w[KO JNJ PG XOM T IBM], from: "2021-09-01", to: "2021-09-03")
          expect(price_list).to be_instance_of Fmp::PriceList
          expect(price_list.responses.count).to eq 2
          expect(price_list.list.count).to eq 6
          expect(price_list.flatten.count).to eq 50
        end
      end
    end
  end

  describe "#list" do
    context "シンボルが一つの場合" do
      it "シンボルを key として過去の株価の配列を value に持つハッシュを返す" do
        VCR.use_cassette("models/fmp/price_list/list") do
          expected = {
            "KO" => [
              { adj_close: 56.73, change: 0.27, change_over_time: 0.00478, change_percent: 0.478, close: 56.73, date: "2021-09-03", high: 56.77,
                label: "September 03, 21", low: 56.25, open: 56.46, unadjusted_volume: 9_578_609.0, volume: 9_578_609.0, vwap: 56.58333 },
              { adj_close: 56.77, change: 0.0, change_over_time: 0.0, change_percent: 0.0, close: 56.77, date: "2021-09-02", high: 57.03,
                label: "September 02, 21", low: 56.41, open: 56.77, unadjusted_volume: 11_398_661.0, volume: 11_398_661.0, vwap: 56.73667 },
              { adj_close: 56.69, change: 0.31, change_over_time: 0.0055, change_percent: 0.55, close: 56.69, date: "2021-09-01", high: 56.8,
                label: "September 01, 21", low: 56.28, open: 56.38, unadjusted_volume: 9_404_637.0, volume: 9_404_637.0, vwap: 56.59 },
            ],
          }
          price_list = Fmp::PriceList.historical("KO", from: "2021-09-01", to: "2021-09-03")
          expect(price_list.list.count).to eq 1
          expect(price_list.list).to eq(expected)
        end
      end
    end

    context "シンボルが最大5つまでの複数の場合" do
      it "シンボルを key として過去の株価の配列を value に複数持つハッシュを返す" do
        VCR.use_cassette("models/fmp/price_list/list_for_multiple_symbols") do
          symbols = %w[KO JNJ PG XOM T IBM].sort
          price_list = Fmp::PriceList.historical(symbols, from: "2021-09-01", to: "2021-09-03")
          expect(price_list.list.count).to eq symbols.count
          expect(price_list.list.keys.sort).to eq(symbols)
          first_price_list = price_list.list.first.second
          expect(first_price_list.count).to eq 3
        end
      end
    end
  end
end
