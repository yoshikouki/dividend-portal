# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dividend::Api, type: :model do
  describe ".recent" do
    let!(:expected_keys) do
      [:ex_dividend_on, :records_on, :pays_on, :declares_on, :symbol, :dividend, :adjusted_dividend]
    end

    it "期間指定してAPI経由で配当情報を取得できる" do
      VCR.use_cassette("models/dividend/api/recent") do
        actual = Dividend::Api.recent
        expect(actual.class).to eq Array
        expect(actual[0].keys).to eq expected_keys
      end
    end
  end

  describe ".all" do
    let!(:expected_keys) do
      [:ex_dividend_on, :records_on, :pays_on, :declares_on, :dividend, :adjusted_dividend, :symbol]
    end

    context "シンボルが単数の場合" do
      it "期間指定してAPI経由で配当情報を取得できる" do
        VCR.use_cassette("models/dividend/api/all") do
          actual = Dividend::Api.all("KO")
          expect(actual.class).to eq Array
          expect(actual[0].keys).to eq expected_keys
        end
      end
    end
  end

  describe ".outlook" do
    context "シンボルが単数の場合" do
      it "期間指定してAPI経由で配当情報を取得できる" do
        VCR.use_cassette("models/dividend/api/outlook") do
          actual = Dividend::Api.outlook("KO")
          expect(actual.class).to eq Hash
          expect(actual.keys).to eq [:symbol, :price, :ttm, :dividends]
        end
      end
    end
  end

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
      actual = Dividend::Api.convert_response_of_dividend_calendar(dividends)
      expect(actual.first[:ex_dividend_on]).to eq expected.first[:ex_dividend_on]
      expect(actual.first[:dividend]).to eq expected.first[:dividend]
    end
  end
end
