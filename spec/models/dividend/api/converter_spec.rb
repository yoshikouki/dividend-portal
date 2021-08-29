# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dividend::Api::Converter, type: :model do
  describe ".convert_response_of_dividend_calendar" do
    it "FMPのレスポンスをハッシュに変換するして返す" do
      expected = [
        { ex_dividend_on: "2020-08-07",
          records_on: "2020-08-10",
          pays_on: "2020-09-10",
          declares_on: "2020-07-28",
          symbol: "IBM",
          dividend: 1.63,
          adjusted_dividend: 1.63 },
      ]
      dividends = [
        { date: "2020-08-07",
          label: "August 07, 20",
          adj_dividend: 1.63,
          symbol: "IBM",
          dividend: 1.63,
          record_date: "2020-08-10",
          payment_date: "2020-09-10",
          declaration_date: "2020-07-28" },
      ]
      actual = Dividend::Api::Converter.convert_response_of_dividend_calendar(dividends)
      expect(actual.first[:ex_dividend_on]).to eq expected.first[:ex_dividend_on]
      expect(actual.first[:dividend]).to eq expected.first[:dividend]
    end
  end

  describe ".calculate_total_split_number" do
    let!(:historical_stock_splits) do
      [{ date: "2012-08-13", numerator: 2.0, denominator: 1.0, label: "August 13, 12" },
       { date: "1996-05-13", numerator: 2.0, denominator: 1.0, label: "May 13, 96" },
       { date: "1992-05-12", numerator: 2.0, denominator: 1.0, label: "May 12, 92" },
       { date: "1990-05-14", numerator: 2.0, denominator: 1.0, label: "May 14, 90" },
       { date: "1986-07-01", numerator: 3.0, denominator: 1.0, label: "July 01, 86" },
       { date: "1977-06-01", numerator: 2.0, denominator: 1.0, label: "June 01, 77" },
       { date: "1968-06-03", numerator: 2.0, denominator: 1.0, label: "June 03, 68" },
       { date: "1965-05-19", numerator: 2.0, denominator: 1.0, label: "May 19, 65" },
       { date: "1965-02-19", numerator: 2.0, denominator: 1.0, label: "February 19, 65" }]
    end
    let!(:expected) do
      {
        Date.parse("2012-08-13") => 2,
        Date.parse("1996-05-13") => 4,
        Date.parse("1992-05-12") => 8,
        Date.parse("1990-05-14") => 16,
        Date.parse("1986-07-01") => 48,
        Date.parse("1977-06-01") => 96,
        Date.parse("1968-06-03") => 192,
        Date.parse("1965-05-19") => 384,
        Date.parse("1965-02-19") => 768,
      }
    end

    it "株式分割の結果、現在の株式から合計何分割されたのか計算する" do
      expect(Dividend::Api::Converter.calculate_total_split_number(historical_stock_splits)).to eq expected
    end

    context "引数が時系列順ではなかった場合" do
      it "TODO: 時系列順に並び替えて計算する" do
        skip "APIのレスポンスは時系列順なので、不具合出たら実装する"
        shuffled_historical_stock_splits = historical_stock_splits.shuffle
        expect(Dividend::Api::Converter.calculate_total_split_number(shuffled_historical_stock_splits)).to eq expected
      end
    end
  end
end
