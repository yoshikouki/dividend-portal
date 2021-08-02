# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company::Api, type: :model do
  describe ".fetch_us" do
    let!(:api_response) do
      [
        { symbol: "SPY", name: "SPDR S&P 500 ETF Trust", price: 438.51, exchange: "New York Stock Exchange Arca" },
        { symbol: "KMI", name: "Kinder Morgan, Inc.", price: 17.38, exchange: "New York Stock Exchange" },
        { symbol: "REGL", name: "ProShares S&P MidCap 400 Dividend Aristocrats ETF", price: 71.47, exchange: "BATS Exchange"},
        { symbol: "INTC", name: "Intel Corporation", price: 53.72, exchange: "Nasdaq Global Select" },
      ]
    end

    it "FMPから取得した生データをインスタンスメソッドに変換して返す" do
      allow(Client::Fmp).to receive(:get_symbols_list).and_return(api_response)
      expected = [
        Company.new(symbol: "SPY", name: "SPDR S&P 500 ETF Trust", exchange: "New York Stock Exchange Arca" ),
        Company.new(symbol: "KMI", name: "Kinder Morgan, Inc.", exchange: "New York Stock Exchange" ),
        Company.new(symbol: "INTC", name: "Intel Corporation", exchange: "Nasdaq Global Select" ),
      ]
      actual = Company::Api.fetch_us
      expect(actual).to eq expected
      expect(actual.count).to eq 3
    end
  end
end
