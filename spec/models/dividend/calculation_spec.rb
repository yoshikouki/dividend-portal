# frozen_string_literal: true

require "rails_helper"

describe "Dividend::Calculation 配当の計算を担う" do
  describe ".dividend_growth_rate" do
    let!(:dividends) do
      [
        { ex_dividend_on: "2021-12-01", adjusted_dividend: 0.1 },
        { ex_dividend_on: "2021-09-01", adjusted_dividend: 0.1 },
        { ex_dividend_on: "2021-06-01", adjusted_dividend: 0.1 },
        { ex_dividend_on: "2021-03-01", adjusted_dividend: 0.1 },
        { ex_dividend_on: "2020-12-01", adjusted_dividend: 0.01 },
        { ex_dividend_on: "2020-09-01", adjusted_dividend: 0.01 },
        { ex_dividend_on: "2020-06-01", adjusted_dividend: 0.01 },
        { ex_dividend_on: "2020-03-01", adjusted_dividend: 0.01 },
        { ex_dividend_on: "2019-12-01", adjusted_dividend: 0.001 },
        { ex_dividend_on: "2019-09-01", adjusted_dividend: 0.001 },
        { ex_dividend_on: "2019-06-01", adjusted_dividend: 0.001 },
        { ex_dividend_on: "2019-03-01", adjusted_dividend: 0.001 },
        { ex_dividend_on: "2018-12-01", adjusted_dividend: 0.0001 },
        { ex_dividend_on: "2018-09-01", adjusted_dividend: 0.0001 },
        { ex_dividend_on: "2018-06-01", adjusted_dividend: 0.0001 },
        { ex_dividend_on: "2018-03-01", adjusted_dividend: 0.0001 },
      ]
    end

    it "増配率の計算結果を配当ごとにマージする" do
      expected = [
        { ex_dividend_on: "2021-12-01", adjusted_dividend: 0.1, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2021-09-01", adjusted_dividend: 0.1, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2021-06-01", adjusted_dividend: 0.1, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2021-03-01", adjusted_dividend: 0.1, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2020-12-01", adjusted_dividend: 0.01, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2020-09-01", adjusted_dividend: 0.01, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2020-06-01", adjusted_dividend: 0.01, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2020-03-01", adjusted_dividend: 0.01, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2019-12-01", adjusted_dividend: 0.001, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2019-09-01", adjusted_dividend: 0.001, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2019-06-01", adjusted_dividend: 0.001, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2019-03-01", adjusted_dividend: 0.001, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2018-12-01", adjusted_dividend: 0.0001, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2018-09-01", adjusted_dividend: 0.0001, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2018-06-01", adjusted_dividend: 0.0001, dividend_growth_rate: 1.0 },
        { ex_dividend_on: "2018-03-01", adjusted_dividend: 0.0001, dividend_growth_rate: 1.0 },
      ]
      expect(Dividend::Calculation.dividend_growth_rate(dividends)).to eq expected
    end
  end
end
