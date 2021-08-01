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
        same_company = Company.new(symbol: "WFC-PZ", name: "Wells Fargo & Company", exchange: "New York Stock Exchange")
        expect(company.diff?(same_company, check_list)).to be false
      end
    end
  end

  describe ".update_to_least" do
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
        allow(Client::Fmp).to receive(:get_symbols_list).and_return(api_response)
        expect { Company.update_to_least }.to change { Company.all.count }.by(api_response.count)
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
        allow(Client::Fmp).to receive(:get_symbols_list).and_return(api_response)
        Company.update_to_least
        expect(Company.all.count).to eq(api_response.count + 1)
        expect(Company.find_by(symbol: "SPY").exchange).to eq "New York Stock Exchange Arca"
        expect(Company.find_by(symbol: "KMI").name).to eq "Kinder Morgan, Inc."
      end
    end
  end
end
