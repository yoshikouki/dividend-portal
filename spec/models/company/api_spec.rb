# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company::Api, type: :model do
  describe ".fetch_us" do
    let!(:api_response) do
      [
        { symbol: "SPY", name: "SPDR S&P 500 ETF Trust", price: 438.51, exchange: "New York Stock Exchange Arca" },
        { symbol: "KMI", name: "Kinder Morgan, Inc.", price: 17.38, exchange: "New York Stock Exchange" },
        { symbol: "REGL", name: "ProShares S&P MidCap 400 Dividend Aristocrats ETF", price: 71.47, exchange: "BATS Exchange" },
        { symbol: "INTC", name: "Intel Corporation", price: 53.72, exchange: "Nasdaq Global Select" },
      ]
    end

    it "FMPから取得した生データをインスタンスメソッドに変換して返す" do
      allow(Fmp).to receive(:symbols_list).and_return(api_response)
      expected = [
        { symbol: "SPY", name: "SPDR S&P 500 ETF Trust", exchange: "New York Stock Exchange Arca" },
        { symbol: "KMI", name: "Kinder Morgan, Inc.", exchange: "New York Stock Exchange" },
        { symbol: "REGL", name: "ProShares S&P MidCap 400 Dividend Aristocrats ETF", exchange: "BATS Exchange" },
        { symbol: "INTC", name: "Intel Corporation", exchange: "Nasdaq Global Select" },
      ]
      actual = Company::Api.fetch_all
      expect(actual).to eq expected
      expect(actual.count).to eq 4
    end
  end

  describe ".profile" do
    let!(:api_response) do
      [{ symbol: "KO",
         price: 56.88,
         beta: 0.614254,
         vol_avg: 14_358_100,
         mkt_cap: 245_529_329_664,
         last_div: 1.66,
         range: "46.22-57.56",
         changes: -0.15,
         company_name: "The Coca-Cola Company",
         currency: "USD",
         cik: "0000021344",
         isin: "US1912161007",
         cusip: "191216100",
         exchange: "New York Stock Exchange",
         exchange_short_name: "NYSE",
         industry: "Beverages—Non-Alcoholic",
         website: "http://www.coca-colacompany.com",
         description: "The Coca-Cola Company, a beverage company, manufactures, markets, and sells various nonalcoholic beverages worldwide.",
         ceo: "Mr. James Quincey",
         sector: "Consumer Defensive",
         country: "US",
         full_time_employees: "80300",
         phone: "14046762121",
         address: "1 Coca Cola Plz NW",
         city: "Atlanta",
         state: "GEORGIA",
         zip: "30301",
         dcf_diff: -22.44,
         dcf: 58.4493,
         image: "https://financialmodelingprep.com/image-stock/KO.png",
         ipo_date: "1919-09-05",
         default_image: false,
         is_etf: false,
         is_actively_trading: true }]
    end

    it "FMPから取得した生データをCompanyパラメタのHashに変換して返す" do
      allow(Fmp).to receive(:profile).and_return(api_response)
      expected = [
        symbol: "KO",
        name: "The Coca-Cola Company",
        currency: "USD",
        exchange: "New York Stock Exchange",
        exchange_short_name: "NYSE",
        industry: "Beverages—Non-Alcoholic",
        sector: "Consumer Defensive",
        country: "US",
        image: "https://financialmodelingprep.com/image-stock/KO.png",
        ipo_date: "1919-09-05",
      ]
      actual = Company::Api.profiles("KO")
      expect(actual).to eq expected
    end
  end
end
