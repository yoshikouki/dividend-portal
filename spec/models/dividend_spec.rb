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
end
