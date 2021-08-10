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

  describe "#updated?" do
    let!(:dividend) { FactoryBot.create(:dividend) }

    context "引数を元にインスタンスの値を比較して同じ場合" do
      it "false を返す" do
        attributes = {
          ex_dividend_on: Date.today.strftime("%Y-%m-%d"),
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
          ex_dividend_on: Date.today.strftime("%Y-%m-%d"),
          records_on: Date.tomorrow.strftime("%Y-%m-%d"),
          pays_on: Date.today.next_month.strftime("%Y-%m-%d"),
          declares_on: Date.today.last_month.strftime("%Y-%m-%d"),
          symbol: dividend.symbol,
          dividend: 0.1,
          adjusted_dividend: 0.1,
        }
        expect(dividend.updated?(attributes.merge(ex_dividend_on: "2001-12-01"))).to be true
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
end
