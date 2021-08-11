# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dividend::Recent, type: :model do
  valid_params = {
    ex_dividend_on: "2020-08-07",
    records_on: "2020-08-10",
    pays_on: "2020-09-10",
    declares_on: "2020-07-28",
    symbol: "IBM",
    dividend: 1.63,
    adjusted_dividend: 1.63,
  }

  describe "validates" do
    it "正しい" do
      dividend = Dividend::Recent.new(valid_params)
      expect(dividend.valid?).to be true
    end
  end

  describe ".update_to_latest" do
    let!(:company) { FactoryBot.create(:company) }
    let!(:new_company) { FactoryBot.create(:company, symbol: "NEWSYMBOL") }
    let!(:nil_declare) { FactoryBot.create(:company, symbol: "NILDECLARE") }
    let!(:empty_declare) { FactoryBot.create(:company, symbol: "EMPTYDECLARE") }
    let!(:dividend) do
      {
        ex_dividend_on: Date.today.strftime("%Y-%m-%d"),
        records_on: Date.tomorrow.strftime("%Y-%m-%d"),
        pays_on: Date.today.next_month.strftime("%Y-%m-%d"),
        declares_on: Date.today.last_month.strftime("%Y-%m-%d"),
        symbol: company.symbol,
        dividend: 0.1,
        adjusted_dividend: 0.1,
        company_id: company.id,
      }
    end

    it "新しいデータが追加される" do
      Dividend.create!(dividend)
      latest_dividends = [
        dividend,
        dividend.merge(symbol: new_company.symbol, company_id: new_company.id),
        dividend.merge(declares_on: nil, symbol: nil_declare.symbol, company_id: nil_declare.id),
        dividend.merge(declares_on: "", symbol: empty_declare.symbol, company_id: empty_declare.id), # APIレスポンスがnullの場合に、変換処理で空文字になることがあった
      ]
      expect { Dividend::Recent.update_to_latest(latest_dividends) }.to change { Dividend.count }.by(3)
      expect { Dividend::Recent.update_to_latest(latest_dividends) }.to change { Dividend.count }.by(0)
    end
  end

  describe ".update_us_to_latest" do
    let!(:dividend_calendar_response) do
      base_response = { symbol: "XOM", date: "2021-08-12", label: "August 12, 21", adj_dividend: 0.87, dividend: 0.87, record_date: "2021-08-13",
                        payment_date: "2021-09-10", declaration_date: "2021-07-28" }
      [
        base_response,
        base_response.merge(symbol: "NewYorkCo"),
        base_response.merge(symbol: "NYSECo"),
        base_response.merge(symbol: "NASDAQCo"),
        base_response.merge(symbol: "NoUS"),
      ]
    end
    let!(:profile_response) do
      base_response = { symbol: "XOM", company_name: "Exxon Mobil Corporation", currency: "USD",
                        exchange: "New York Stock Exchange", exchange_short_name: "NYSE", industry: "Oil & Gas Integrated", sector: "Energy", country: "US",
                        image: "https://financialmodelingprep.com/image-stock/XOM.png", ipo_date: "1980-03-17" }
      [
        base_response,
        base_response.merge(symbol: "NewYorkCo", exchange: "new york", exchange_short_name: "NYSE"),
        base_response.merge(symbol: "NYSECo", exchange: "NYSE", exchange_short_name: "NYSE"),
        base_response.merge(symbol: "NASDAQCo", exchange: "nasdaq", exchange_short_name: "NASDAQ"),
        base_response.merge(symbol: "NoUS", exchange: "Kagoshima Exchange", exchange_short_name: "KE"),
      ]
    end

    it "US企業の新しいデータが追加される" do
      allow(Client::Fmp).to receive(:get_dividend_calendar).and_return(dividend_calendar_response)
      allow(Client::Fmp).to receive(:profile).and_return(profile_response)

      expect { Dividend::Recent.update_us_to_latest }.to change { Dividend.count }.by(4)
      expect(Company.first.symbol).to eq("XOM")
      expect(Company.last.symbol).to eq("NASDAQCo")
      expect { Dividend::Recent.update_us_to_latest }.to change { Dividend.count }.by(0)
      expect(Dividend.not_notified.count).to eq(4)
    end
  end

  describe ".destroy_outdated" do
    let!(:company) { FactoryBot.create(:company) }

    it "権利落ち日が3日以前の配当金は削除する" do
      FactoryBot.create(
        :dividend,
        :with_company,
        ex_dividend_on: Date.today.prev_day(3),
      )
      FactoryBot.create(
        :dividend,
        :with_company,
        ex_dividend_on: Date.today.prev_day(2),
      )
      expect { Dividend::Recent.destroy_outdated }.to change { Dividend.count }.by(-1)
      expect(Dividend.all.count).to eq 1
    end
  end
end
