# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dividend, type: :model do
  describe "#same?" do
    let!(:dividend) do
      Dividend.create(
        ex_dividend_on: "2021-01-01",
        records_on: "2021-01-01",
        pays_on: "2021-01-01",
        declares_on: "2021-01-01",
        symbol: "TST",
        dividend: 0.1,
        adjusted_dividend: 0.1,
      )
    end

    context "引数の権利落ち日とシンボルと同じ場合" do
      it "true を返す" do
        attributes = {
          ex_dividend_on: "2021-01-01",
          symbol: "TST",
        }
        expect(dividend.same?(attributes)).to be true
      end
    end

    context "引数の権利落ち日とシンボルのどちらかが異なる場合" do
      it "false を返す" do
        ex_dividend_on = {
          ex_dividend_on: "2021-12-31",
          symbol: "TST",
        }
        symbol = {
          ex_dividend_on: "2021-01-01",
          symbol: "NOTEST",
        }
        expect(dividend.same?(ex_dividend_on)).to be false
        expect(dividend.same?(symbol)).to be false
      end
    end
  end

  describe ".insert_all_with_api!" do
    let!(:company) { FactoryBot.create(:company) }
    let!(:new_company) { FactoryBot.create(:company, symbol: "NEWSYMBOL") }
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

    it "デフォルトは米国株の2日前の以後に発表された配当を作成する" do
      Dividend.create!(dividend)
      latest_dividends = [
        dividend,
        dividend.merge(symbol: new_company.symbol, company_id: new_company.id),
      ]
      expect { Dividend.insert_all_with_api!(latest_dividend_calendar: latest_dividends) }.to change { Dividend.count }.by(1)
    end

    context "APIレスポンスに空文字が含まれていた場合" do
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

      it "空文字は nil として扱って新しいデータを追加する" do
        Dividend.create!(dividend)
        latest_dividends = [
          dividend,
          dividend.merge(symbol: new_company.symbol, company_id: new_company.id),
          dividend.merge(declares_on: nil, symbol: nil_declare.symbol, company_id: nil_declare.id),
          dividend.merge(declares_on: "", symbol: empty_declare.symbol, company_id: empty_declare.id), # APIレスポンスがnullの場合に、変換処理で空文字になることがあった
        ]
        expect { Dividend.insert_all_with_api!(latest_dividend_calendar: latest_dividends) }.to change { Dividend.count }.by(3)
        expect { Dividend.insert_all_with_api!(latest_dividend_calendar: latest_dividends) }.to change { Dividend.count }.by(0)
      end
    end
  end

  describe ".insert_all_from_dividend_calendar!" do
    context "Company と関連付けた Dividend をバルクインサートする (デフォルト)" do
      let!(:company) { FactoryBot.create(:company) }
      let!(:new_company) { FactoryBot.create(:company, symbol: "NEWSYMBOL") }
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

      it "企業がなかった場合は新しく Company を作成して Dividend をインサートする" do
        Dividend.create!(dividend)
        dividend_calendar = [
          dividend,
          dividend.merge(symbol: new_company.symbol),
          dividend.merge(symbol: "KO"),
        ]
        VCR.use_cassette("models/dividend/insert_all_from_dividend_calendar/associate_company") do
          expect { Dividend.insert_all_from_dividend_calendar!(dividend_calendar) }
            .to change { Dividend.count }.by(3).and change { Company.count }.by(1)
        end
      end

      it "権利落ち日・シンボルが同一の配当は無視する"
    end

    context "Company との関連付けをスキップする" do
      let!(:dividend) do
        {
          ex_dividend_on: Date.today.strftime("%Y-%m-%d"),
          records_on: nil,
          pays_on: Date.today.next_month.strftime("%Y-%m-%d"),
          declares_on: "",
          symbol: "SYMBOL",
          dividend: 0.1,
          adjusted_dividend: nil,
        }
      end

      it "空文字は nil として扱って新しいデータを追加する" do
        Dividend.create!(dividend)
        dividend_calendar = [
          dividend,
          dividend.merge(symbol: "NEWCOMPANY"),
          dividend.merge(declares_on: "", symbol: "", pays_on: ""), # APIレスポンスがnullの場合に、変換処理で空文字になることがあった
        ]
        expect { Dividend.insert_all_from_dividend_calendar!(dividend_calendar, associate_company: false) }
          .to change { Dividend.count }.by(3).and change { Company.count }.by(0)
      end
    end
  end
end
