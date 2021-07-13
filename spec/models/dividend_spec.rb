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

  describe ".to_instances" do
    it "FMPから取得した生データをインスタンスメソッドに変換して返す" do
      expected = [
        Dividend.new(
          ex_dividend_on: "2020-08-07",
          records_on: "2020-08-10",
          pays_on: "2020-09-10",
          declares_on: "2020-07-28",
          symbol: "IBM",
          dividend: 1.63,
          adjusted_dividend: 1.63,
        ),
      ]
      dividends = [
        { date: "2020-08-07",
          label: "August 07, 20",
          adj_dividend: 1.63,
          symbol: "IBM",
          dividend: 1.63,
          record_date: "2020-08-10",
          payment_date: "2020-09-10",
          declaration_date: "2020-07-28" },
      ]
      actual = Dividend.to_instances(dividends)
      expect(actual.first.ex_dividend_on).to eq expected.first.ex_dividend_on
      expect(actual.first.dividend).to eq expected.first.dividend
    end
  end
end
