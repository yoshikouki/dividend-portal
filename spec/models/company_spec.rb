# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company, type: :model do
  describe "diff?" do
    context "同じ内容だった場合" do
      let!(:company) { FactoryBot.create(:company) }

      it "false を返す" do
        check_list = %i[
          name
          exchange
        ]
        same_company = Company.new(symbol: company.symbol, name: company.name, exchange: company.exchange)
        expect(company.diff?(same_company, check_list)).to be false
      end
    end
  end

  describe ".update_all_to_least" do
    let!(:api_response) do
      [
        { symbol: "SPY", name: "SPDR S&P 500 ETF Trust", price: 438.51, exchange: "New York Stock Exchange Arca" },
        { symbol: "CMCSA", name: "Comcast Corporation", price: 58.83, exchange: "Nasdaq Global Select" },
        { symbol: "KMI", name: "Kinder Morgan, Inc.", price: 17.38, exchange: "New York Stock Exchange" },
        { symbol: "INTC", name: "Intel Corporation", price: 53.72, exchange: "Nasdaq Global Select" },
      ]
    end

    context "DBが空の場合" do
      it "取得した情報を元にレコードを作成する" do
        allow(Fmp).to receive(:get_symbols_list).and_return(api_response)
        expect { Company.update_all_with_api }.to change { Company.all.count }.by(api_response.count)
        expect(Company.last.name).to eq "Intel Corporation"
      end
    end

    context "情報が更新されている場合" do
      before do
        [
          { symbol: "SPY", name: "SPDR S&P 500 ETF Trust", exchange: "NYみたいなところ" },
          { symbol: "CMCSAAAAAAAAAAAAAAA", name: "Comcast Corporation", exchange: "Nasdaq Global Select" },
          { symbol: "KMI", name: "名無し", exchange: "New York Stock Exchange" },
          { symbol: "INTC", name: "Intel Corporation", exchange: "Nasdaq Global Select" },
        ].each { |company| FactoryBot.create(:company, company) }
      end

      it "シンボルを元に作成・更新が行われる" do
        allow(Fmp).to receive(:get_symbols_list).and_return(api_response)
        Company.update_all_with_api
        expect(Company.all.count).to eq(api_response.count + 1)
        expect(Company.find_by(symbol: "SPY").exchange).to eq "New York Stock Exchange Arca"
        expect(Company.find_by(symbol: "KMI").name).to eq "Kinder Morgan, Inc."
      end
    end
  end

  describe "#update_to_least" do
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

    context "DBが空の場合" do
      it "取得した情報を元にレコードを作成する" do
        allow(Fmp).to receive(:profile).and_return(api_response)
        expect { Company.new(symbol: "KO").update_with_api }.to change { Company.all.count }.by(1)
        expect(Company.last.name).to eq "The Coca-Cola Company"
      end
    end

    context "情報が更新されている場合" do
      let!(:company) { FactoryBot.create(:company, symbol: "KO", name: "Kora-Kola") }

      it "シンボルを元に作成・更新が行われる" do
        allow(Fmp).to receive(:profile).and_return(api_response)
        expect { company.update_with_api }.to change { Company.all.count }.by(0)
        expect(company.reload.name).to eq "The Coca-Cola Company"
      end
    end
  end
end
