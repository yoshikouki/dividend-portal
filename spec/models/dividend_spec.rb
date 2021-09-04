# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dividend, type: :model do
  describe "filter_by_condition" do
    dividends = [
      { date: "2021-07-09",
        label: "July 09, 21",
        adj_dividend: 0.4025,
        symbol: "OGE",
        dividend: 0.4025,
        record_date: "2021-07-12",
        payment_date: "2021-07-30",
        declaration_date: "2021-05-20" },
      { date: "2021-07-09",
        label: "July 09, 21",
        adj_dividend: 0.09,
        symbol: "MANU",
        dividend: 0.09,
        record_date: "2021-07-12",
        payment_date: "2021-07-30",
        declaration_date: "2021-06-17" },
      { date: "2021-07-09",
        label: "July 09, 21",
        adj_dividend: 0.42,
        symbol: "LNC",
        dividend: 0.42,
        record_date: "2021-07-12",
        payment_date: "2021-08-02",
        declaration_date: "2021-06-03" },
    ]
    context "配当発表日の場合" do
      it "渡された日時以降の発表分を返す" do
        expect = [
          { date: "2021-07-09",
            label: "July 09, 21",
            adj_dividend: 0.09,
            symbol: "MANU",
            dividend: 0.09,
            record_date: "2021-07-12",
            payment_date: "2021-07-30",
            declaration_date: "2021-06-17" },
          { date: "2021-07-09",
            label: "July 09, 21",
            adj_dividend: 0.42,
            symbol: "LNC",
            dividend: 0.42,
            record_date: "2021-07-12",
            payment_date: "2021-08-02",
            declaration_date: "2021-06-03" },
        ]
        got = Dividend.filter_by_condition(dividends, :declaration_date, Time.parse("2021-06-03"))
        expect(got).to eq(expect)
      end
    end
  end

  describe "#same?" do
    let!(:dividend) do
      Dividend.create(
        ex_dividend_date: "2021-01-01",
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
          ex_dividend_date: "2021-01-01",
          symbol: "TST",
        }
        expect(dividend.same?(attributes)).to be true
      end
    end

    context "引数の権利落ち日とシンボルのどちらかが異なる場合" do
      it "false を返す" do
        ex_dividend_date = {
          ex_dividend_date: "2021-12-31",
          symbol: "TST",
        }
        symbol = {
          ex_dividend_date: "2021-01-01",
          symbol: "NOTEST",
        }
        expect(dividend.same?(ex_dividend_date)).to be false
        expect(dividend.same?(symbol)).to be false
      end
    end
  end

  describe "#updated?" do
    let!(:company) { FactoryBot.create(:company) }
    let!(:dividend) { FactoryBot.create(:dividend, :with_company) }

    context "引数を元にインスタンスの値を比較して同じ場合" do
      it "false を返す" do
        attributes = {
          ex_dividend_date: Date.today.strftime("%Y-%m-%d"),
          records_on: Date.tomorrow.strftime("%Y-%m-%d"),
          pays_on: Date.today.next_month.strftime("%Y-%m-%d"),
          declares_on: Date.today.last_month.strftime("%Y-%m-%d"),
          symbol: dividend.symbol,
          dividend: 0.1,
          adjusted_dividend: 0.1,
        }
        expect(dividend.updated?(attributes)).to be false
      end
    end

    context "引数を元にインスタンスの値を比較して異なっていた場合" do
      it "true を返す" do
        attributes = {
          ex_dividend_date: Date.today.strftime("%Y-%m-%d"),
          records_on: Date.tomorrow.strftime("%Y-%m-%d"),
          pays_on: Date.today.next_month.strftime("%Y-%m-%d"),
          declares_on: Date.today.last_month.strftime("%Y-%m-%d"),
          symbol: dividend.symbol,
          dividend: 0.1,
          adjusted_dividend: 0.1,
        }
        expect(dividend.updated?(attributes.merge(ex_dividend_date: "2001-12-01"))).to be true
        expect(dividend.updated?(attributes.merge(records_on: "2001-12-01"))).to be true
        expect(dividend.updated?(attributes.merge(pays_on: "2001-12-01"))).to be true
        expect(dividend.updated?(attributes.merge(declares_on: "2001-12-01"))).to be true
        expect(dividend.updated?(attributes.merge(symbol: "NOTST"))).to be true
        expect(dividend.updated?(attributes.merge(dividend: 0.00001))).to be true
        expect(dividend.updated?(attributes.merge(adjusted_dividend: 0.00001))).to be true
        expect(dividend.updated?(attributes)).to be false
      end
    end
  end

  describe ".insert_all_with_api!" do
    let!(:company) { FactoryBot.create(:company) }
    let!(:new_company) { FactoryBot.create(:company, symbol: "NEWSYMBOL") }
    let!(:dividend) do
      {
        ex_dividend_date: Date.today.strftime("%Y-%m-%d"),
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
          ex_dividend_date: Date.today.strftime("%Y-%m-%d"),
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
          ex_dividend_date: "2021-09-01",
          records_on: "2021-09-02",
          pays_on: "2021-10-01",
          declares_on: "2021-08-01",
          symbol: company.symbol,
          dividend: 0.1,
          adjusted_dividend: 0.1,
          company_id: company.id,
        }
      end

      it "企業がなかった場合は新しく Company を作成して Dividend をインサートする" do
        dividend_calendar = [
          dividend,
          dividend.merge(symbol: new_company.symbol, ex_dividend_date: "2021-12-01"),
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
          ex_dividend_date: Date.today.strftime("%Y-%m-%d"),
          records_on: nil,
          pays_on: Date.today.next_month.strftime("%Y-%m-%d"),
          declares_on: "",
          symbol: "SYMBOL",
          dividend: 0.1,
          adjusted_dividend: nil,
        }
      end

      it "空文字は nil として扱って新しいデータを追加する" do
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
