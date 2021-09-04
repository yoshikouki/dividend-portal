# frozen_string_literal: true

require "rails_helper"

describe "Fmp::Dividend" do
  describe "#to_dividend_attributes" do
    context "全てのインスタンス変数が揃っている場合" do
      it "シンボルに関する過去の配当を返す" do
        dividend = Fmp::Dividend.new(
          date: "2021-01-01",
          symbol: "TEST",
          dividend: 0.1,
          adj_dividend: 0.1,
          label: "2021-01-01",
          declaration_date: "2021-01-01",
          record_date: "2021-01-01",
          payment_date: "2021-01-01",
        )
        expected = {
          ex_dividend_on: "2021-01-01",
          symbol: "TEST",
          dividend: 0.1,
          adjusted_dividend: 0.1,
          declares_on: "2021-01-01",
          records_on: "2021-01-01",
          pays_on: "2021-01-01",
        }
        expect(dividend.to_dividend_attributes).to eq(expected)
      end
    end

    context "空のインスタンス変数がある場合" do
      it "複数のシンボルに関する過去の配当を配列で返す" do
        dividend = Fmp::Dividend.new(
          date: "2021-01-01",
          symbol: "TEST",
          dividend: 0.1,
          adj_dividend: nil,
          label: "2021-01-01",
          declaration_date: "",
          )
        expected = {
          ex_dividend_on: "2021-01-01",
          symbol: "TEST",
          dividend: 0.1,
          adjusted_dividend: nil,
          declares_on: nil,
          records_on: nil,
          pays_on: nil,
        }
        expect(dividend.to_dividend_attributes).to eq(expected)
      end
    end
  end
end
