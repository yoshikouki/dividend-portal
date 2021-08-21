# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::Content::DividendReport, type: :model do
  describe "#new_dividend_of_dividend_aristocrats" do
    let!(:company) { FactoryBot.create(:company, symbol: "ADM", name: "Archer-Daniels-Midland Company", years_of_dividend_growth: 47) }
    let!(:dividend) { FactoryBot.create(:dividend, symbol: "ADM", company: company) }
    let!(:report_queue) { FactoryBot.create(:report_queue_of_dividend_aristocrats_dividend, dividend: dividend) }

    context "正常系" do
      let!(:base) do
        { date: "2021-08-17", label: "August 17, 21", record_date: "2021-08-18", payment_date: "2021-09-08", declaration_date: "2021-08-04",
          adj_dividend: 0.37, dividend: 0.37 }
      end
      let!(:historical_dividends_response) do
        { symbol: "ADM",
          historical: [base,
                       base.merge(date: "2021-05-18", dividend: 0.37),
                       base.merge(date: "2021-02-08", dividend: 0.37),
                       base.merge(date: "2020-11-18", dividend: 0.36),
                       base.merge(date: "2020-08-18", dividend: 0.36),
                       base.merge(date: "2020-05-19", dividend: 0.36),
                       base.merge(date: "2020-02-12", dividend: 0.36),
                       base.merge(date: "2019-11-20", dividend: 0.35),
                       base.merge(date: "2019-08-21", dividend: 0.35),
                       base.merge(date: "2019-05-14", dividend: 0.35),
                       base.merge(date: "2019-02-15", dividend: 0.35),
                       base.merge(date: "2018-11-21", dividend: 0.335)] }
      end
      let!(:company_outlook_response) do
        {
          profile: { symbol: "JNJ", price: 179.44 },
          ratios: [{ payout_ratio_ttm: 0.6060069229470366, dividend_yield_ttm: 0.022793134195274185, dividend_per_share_ttm: 4.09 }],
          stock_dividend: historical_dividends_response,
        }
      end

      it "素のテンプレートを返す" do
        allow(Client::Fmp).to receive(:historical_dividends).and_return(historical_dividends_response)
        allow(Client::Fmp).to receive(:company_outlook).and_return(company_outlook_response)
        actual = Tweet::Content::DividendReport.new.new_dividend_of_dividend_aristocrats(report_queue)
        expected = <<~TWEET 
          #配当貴族 $ADM の新着配当金情報です

          企業名 Archer-Daniels-Midland Company
          配当 $0.1
          配当比率 %
          増配比率 -0.229% (-0.33)
          増配年数 年
          配当支給日 2021-09-17
          権利落ち日 2021-08-17
        TWEET
        expect(actual).to eq expected
      end
    end
  end

  describe "#total_result_of_this_year" do
    let!(:base) do
      { ex_dividend_on: "2021-08-17", records_on: "2021-08-18", pays_on: "2021-09-08", declares_on: "2021-08-04",
        dividend: 0.37, adjusted_dividend: 0.37, symbol: "ADM" }
    end
    let!(:dividends) do
      [
        base,
        base.merge(ex_dividend_on: "2021-05-18", dividend: 0.37),
        base.merge(ex_dividend_on: "2021-02-08", dividend: 0.37),
        base.merge(ex_dividend_on: "2020-11-18", dividend: 0.36),
        base.merge(ex_dividend_on: "2020-08-18", dividend: 0.36),
        base.merge(ex_dividend_on: "2020-05-19", dividend: 0.36),
        base.merge(ex_dividend_on: "2020-02-12", dividend: 0.36),
        base.merge(ex_dividend_on: "2019-11-20", dividend: 0.35),
        base.merge(ex_dividend_on: "2019-08-21", dividend: 0.35),
        base.merge(ex_dividend_on: "2019-05-14", dividend: 0.35),
        base.merge(ex_dividend_on: "2019-02-15", dividend: 0.35),
        base.merge(ex_dividend_on: "2018-11-21", dividend: 0.335),
      ]
    end

    it "最も新しい配当の年について集計結果を返す" do
      actual = Tweet::Content::DividendReport.new.total_result_of_this_year(dividends)
      expected = {
        annualized_dividend: 1.11,
        dividend_count: 3,
        dividend_increase: -0.33,
        incremental_dividend_rate: -0.229,
      }
      expect(actual).to eq expected
    end
  end

  describe "#calculate_annually" do
    context "正常系-同じシンボルの過去の配当情報をDIVIDEND_CALENDAR形式の配列で取得した場合" do
      let!(:base) do
        { ex_dividend_on: "2021-08-17", records_on: "2021-08-18", pays_on: "2021-09-08", declares_on: "2021-08-04",
          dividend: 0.37, adjusted_dividend: 0.37, symbol: "ADM" }
      end
      let!(:dividends) do
        [
          base,
          base.merge(ex_dividend_on: "2021-05-18", dividend: 0.37),
          base.merge(ex_dividend_on: "2021-02-08", dividend: 0.37),
          base.merge(ex_dividend_on: "2020-11-18", dividend: 0.36),
          base.merge(ex_dividend_on: "2020-08-18", dividend: 0.36),
          base.merge(ex_dividend_on: "2020-05-19", dividend: 0.36),
          base.merge(ex_dividend_on: "2020-02-12", dividend: 0.36),
          base.merge(ex_dividend_on: "2019-11-20", dividend: 0.35),
          base.merge(ex_dividend_on: "2019-08-21", dividend: 0.35),
          base.merge(ex_dividend_on: "2019-05-14", dividend: 0.35),
          base.merge(ex_dividend_on: "2019-02-15", dividend: 0.35),
          base.merge(ex_dividend_on: "2018-11-21", dividend: 0.335),
        ]
      end

      it "1-12月を一年の単位として集計した配当情報を返す" do
        actual = Tweet::Content::DividendReport.new.calculate_annually(dividends)
        expected = { 2021 => { annualized_dividend: 1.11, dividend_count: 3 },
                     2020 => { annualized_dividend: 1.44, dividend_count: 4 },
                     2019 => { annualized_dividend: 1.4, dividend_count: 4 },
                     2018 => { annualized_dividend: 0.335, dividend_count: 1 } }
        expect(actual).to eq expected
      end
    end
  end
end
