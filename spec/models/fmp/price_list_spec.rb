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
          expect(price_list.flatten.count).to eq 3
        end
      end
    end

    context "シンボルが複数の場合" do
      it "複数のシンボルに関する過去の株価をまとめた PriceList インスタンスで返す" do
        VCR.use_cassette("models/fmp/price_list/historical_for_multiple_symbols") do
          symbols = %w[KO JNJ PG XOM T IBM]
          price_list = Fmp::PriceList.historical(symbols, from: "2021-09-01", to: "2021-09-03")
          expect(price_list).to be_instance_of Fmp::PriceList
          expect(price_list.responses.count).to eq 2
          expect(price_list.list.count).to eq symbols.count
          expect(price_list.flatten.count).to eq(symbols.count * 3)
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

    context "シンボルが複数の場合" do
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

  describe "#flatten" do
    context "シンボルが一つの場合" do
      it "シンボルを key として過去の株価の配列を value に持つハッシュを返す" do
        VCR.use_cassette("models/fmp/price_list/flatten") do
          expected = [
            { symbol: "KO", adj_close: 56.69, change: 0.31, change_over_time: 0.0055, change_percent: 0.55, close: 56.69, date: "2021-09-01", high: 56.8,
              label: "September 01, 21", low: 56.28, open: 56.38, unadjusted_volume: 9_404_637.0, volume: 9_404_637.0, vwap: 56.59 },
            { symbol: "KO", adj_close: 56.77, change: 0.0, change_over_time: 0.0, change_percent: 0.0, close: 56.77, date: "2021-09-02", high: 57.03,
              label: "September 02, 21", low: 56.41, open: 56.77, unadjusted_volume: 11_398_661.0, volume: 11_398_661.0, vwap: 56.73667 },
            { symbol: "KO", adj_close: 56.73, change: 0.27, change_over_time: 0.00478, change_percent: 0.478, close: 56.73, date: "2021-09-03", high: 56.77,
              label: "September 03, 21", low: 56.25, open: 56.46, unadjusted_volume: 9_578_609.0, volume: 9_578_609.0, vwap: 56.58333 },
          ]
          price_list = Fmp::PriceList.historical("KO", from: "2021-09-01", to: "2021-09-03")
          expect(price_list.flatten.count).to eq 3
          expect(price_list.flatten).to eq(expected)
        end
      end
    end

    context "シンボルが複数の場合" do
      it "シンボルを key として過去の株価の配列を value に複数持つハッシュを返す" do
        VCR.use_cassette("models/fmp/price_list/flatten_for_multiple_symbols") do
          symbols = %w[KO JNJ PG XOM T IBM].sort
          price_list = Fmp::PriceList.historical(symbols, from: "2021-09-01", to: "2021-09-03")
          expect(price_list.flatten.count).to eq symbols.count * 3
          expect(price_list.flatten.pluck(:symbol).uniq.sort).to eq(symbols)
        end
      end

      it "戻り値は日付順にソートされている" do
        VCR.use_cassette("models/fmp/price_list/flatten_for_multiple_symbols") do
          symbols = %w[KO JNJ PG XOM T IBM].sort
          price_list = Fmp::PriceList.historical(symbols, from: "2021-09-01", to: "2021-09-03")
          expect(price_list.flatten[-6..].pluck(:symbol).uniq.sort).to eq(symbols)
        end
      end
    end
  end

  describe "#to_prices_attributes" do
    context "シンボルが一つの場合" do
      it "Price::History の引数に変換する" do
        VCR.use_cassette("models/fmp/price_list/flatten") do
          expected = [
            { symbol: "KO", adjusted_close: 56.69, change: 0.31, change_over_time: 0.0055, change_percent: 0.55, close: 56.69, date: "2021-09-01",
              high: 56.8, low: 56.28, open: 56.38, unadjusted_volume: 9_404_637.0, volume: 9_404_637.0, vwap: 56.59 },
            { symbol: "KO", adjusted_close: 56.77, change: 0.0, change_over_time: 0.0, change_percent: 0.0, close: 56.77, date: "2021-09-02",
              high: 57.03, low: 56.41, open: 56.77, unadjusted_volume: 11_398_661.0, volume: 11_398_661.0, vwap: 56.73667 },
            { symbol: "KO", adjusted_close: 56.73, change: 0.27, change_over_time: 0.00478, change_percent: 0.478, close: 56.73, date: "2021-09-03",
              high: 56.77, low: 56.25, open: 56.46, unadjusted_volume: 9_578_609.0, volume: 9_578_609.0, vwap: 56.58333 },
          ]
          price_list = Fmp::PriceList.historical("KO", from: "2021-09-01", to: "2021-09-03")
          expect(price_list.to_prices_attributes.count).to eq 3
          expect(price_list.to_prices_attributes).to eq(expected)
        end
      end

      it "丸め誤差は修正されている" do
        VCR.use_cassette("models/fmp/price_list/to_prices_attributes_for_rounding_error") do
          price_list = Fmp::PriceList.historical("ALB", from: "2021-09-13", to: "2021-09-14")
          expected = [
            {
              date: "2021-09-13",
              open: 242.93,
              high: 243.25,
              low: 222.45,
              close: 229.13,
              adjusted_close: 228.75,
              volume: 2_522_900.0,
              unadjusted_volume: 2_522_900.0,
              change: -13.8,
              change_percent: -5.681,
              vwap: 231.61,
              change_over_time: -0.05681,
              symbol: "ALB",
            },
            {
              date: "2021-09-14",
              open: 232.2,
              high: 235.0,
              low: 228.74,
              close: 230.47,
              adjusted_close: 230.09,
              volume: 1_322_400.0,
              unadjusted_volume: 1_322_400.0,
              change: -1.73,
              change_percent: -0.745,
              vwap: 231.40334,
              change_over_time: -0.00745,
              symbol: "ALB",
            },
          ]
          expect(price_list.to_prices_attributes).to eq(expected)
        end
      end
    end
  end

  describe "#to_price_history" do
    context "シンボルが一つの場合" do
      it "Price::History のインスタンスを返す" do
        VCR.use_cassette("models/fmp/price_list/flatten") do
          price_history = Fmp::PriceList.historical("KO", from: "2021-09-01", to: "2021-09-03")
                                        .to_price_history
          expect(price_history).to be_instance_of Price::History
          expect(price_history.prices.first).to be_instance_of Price
          expect(price_history.prices.count).to eq 3
        end
      end
    end
  end
end
