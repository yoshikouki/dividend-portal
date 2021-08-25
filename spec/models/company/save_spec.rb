# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company::Save, type: :model do
  describe ".create_for_us_with_api" do
    let!(:base_profile) do
      { symbol: "KO",
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
        is_actively_trading: true }
    end
    let!(:api_response) do
      [
        base_profile,
        base_profile.merge(symbol: "NYSECOMPANY", exchange: "NYSE"),
        base_profile.merge(symbol: "NASDAQCOMPANY", exchange: "nasdaq"),
        base_profile.merge(symbol: "NOUS", exchange: "Tokyo"),
      ]
    end

    it "引数のシンボル配列の中から米国企業だけをDBに保存する" do
      allow(Fmp).to receive(:profile).and_return(api_response)
      symbols = api_response.pluck(:symbol)
      expect { Company::Save.create_for_us_with_api(symbols) }.to change(Company, :count).by(3)
      expect(Company.last.symbol).to eq "NASDAQCOMPANY"
    end
  end
end
