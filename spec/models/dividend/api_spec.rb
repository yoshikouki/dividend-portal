# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dividend::Api, type: :model do
  describe ".recent" do
    let!(:expected_keys) do
      %i[ex_dividend_on records_on pays_on declares_on symbol dividend adjusted_dividend]
    end

    it "期間指定してAPI経由で配当情報を取得できる" do
      VCR.use_cassette("models/dividend/api/recent") do
        actual = Dividend::Api.recent(from: "2021-08-27")
        expect(actual.class).to eq Array
        expect(actual[0].keys).to eq expected_keys
      end
    end
  end

  describe ".all" do
    let!(:expected_keys) do
      %i[ex_dividend_on records_on pays_on declares_on dividend adjusted_dividend symbol]
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
    it "配当に関係する企業情報が取得できる" do
      VCR.use_cassette("models/dividend/api/outlook") do
        actual = Dividend::Api.outlook("KO")
        expect(actual.class).to eq Hash
        expect(actual.keys).to eq %i[symbol price ttm dividends]
      end
    end
  end

  describe ".all_adjusted " do
    it "過去の株式分割を考慮した配当の調整後金額を含めた配当情報を取得する" do
      VCR.use_cassette("models/dividend/api/all_adjusted") do
        actual = Dividend::Api.all_adjusted("KO")
        expected_latest_dividend = {
          ex_dividend_on: "2021-06-14",
          records_on: "2021-06-15",
          pays_on: "2021-07-01",
          declares_on: "2021-04-21",
          dividend: 0.42,
          adjusted_dividend: 0.42,
          symbol: "KO",
        }
        expected_oldest_dividend = {
          ex_dividend_on: "1962-03-13",
          dividend: 0.00156,
          adjusted_dividend: 0.00000203125,
          symbol: "KO",
        }
        expect(actual.class).to eq Array
        expect(actual.first).to eq expected_latest_dividend
        expect(actual.last).to eq expected_oldest_dividend
      end
    end
  end
end
