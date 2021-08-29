# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dividend::Api, type: :model do
  describe ".recent" do
    let!(:expected_keys) do
      %i[ex_dividend_on records_on pays_on declares_on symbol dividend adjusted_dividend]
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
    context "シンボルが単数の場合" do
      it "期間指定してAPI経由で配当情報を取得できる" do
        VCR.use_cassette("models/dividend/api/outlook") do
          actual = Dividend::Api.outlook("KO")
          expect(actual.class).to eq Hash
          expect(actual.keys).to eq %i[symbol price ttm dividends]
        end
      end
    end
  end
end
