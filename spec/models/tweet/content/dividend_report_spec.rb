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

  describe "#calculate_result_of_dividend_increase" do
    let!(:today) { Date.today }
    let!(:base) do
      { ex_dividend_on: today.strftime("%Y-%m-%d"), records_on: today.tomorrow.strftime("%Y-%m-%d"),
        pays_on: today.next_week.strftime("%Y-%m-%d"), declares_on: today.last_week.strftime("%Y-%m-%d"),
        dividend: 0.1, adjusted_dividend: 0.37, symbol: "ADM" }
    end
    let!(:dividends) do
      [
        base,
        base.merge(ex_dividend_on: today.months_ago(3).strftime("%Y-%m-%d"), dividend: 0.1),
        base.merge(ex_dividend_on: today.months_ago(6).strftime("%Y-%m-%d"), dividend: 0.1),
        base.merge(ex_dividend_on: today.months_ago(9).strftime("%Y-%m-%d"), dividend: 0.1),
        base.merge(ex_dividend_on: today.years_ago(1).strftime("%Y-%m-%d"), dividend: 0.01),
        base.merge(ex_dividend_on: today.years_ago(1).months_ago(3).strftime("%Y-%m-%d"), dividend: 0.01),
        base.merge(ex_dividend_on: today.years_ago(1).months_ago(6).strftime("%Y-%m-%d"), dividend: 0.01),
        base.merge(ex_dividend_on: today.years_ago(1).months_ago(9).strftime("%Y-%m-%d"), dividend: 0.01),
        base.merge(ex_dividend_on: today.years_ago(2).strftime("%Y-%m-%d"), dividend: 0.001),
        base.merge(ex_dividend_on: today.years_ago(2).months_ago(3).strftime("%Y-%m-%d"), dividend: 0.001),
        base.merge(ex_dividend_on: today.years_ago(2).months_ago(6).strftime("%Y-%m-%d"), dividend: 0.001),
        base.merge(ex_dividend_on: today.years_ago(2).months_ago(9).strftime("%Y-%m-%d"), dividend: 0.001),
      ]
    end

    it "過去12ヶ月の増配金額と増配率をハッシュで返す" do
      actual = Tweet::Content::DividendReport.new.calculate_changed_dividend_and_its_rate_from_dividends(dividends)
      expected = {
        annualized_dividend: 0.4,
        changed_dividend: 0.36,
        changed_dividend_rate: 9,
      }
      expect(actual).to eq expected
    end
  end

  describe "#aggregate_by_12_months" do
    context "正常系-同じシンボルの過去の配当情報をDIVIDEND_CALENDAR形式の配列で取得した場合" do
      let!(:today) { Date.today }
      let!(:base) do
        { ex_dividend_on: today.strftime("%Y-%m-%d"), records_on: today.tomorrow.strftime("%Y-%m-%d"),
          pays_on: today.next_week.strftime("%Y-%m-%d"), declares_on: today.last_week.strftime("%Y-%m-%d"),
          dividend: 0.1, adjusted_dividend: 0.37, symbol: "ADM" }
      end
      let!(:dividends) do
        [
          base,
          base.merge(ex_dividend_on: today.months_ago(3).strftime("%Y-%m-%d"), dividend: 0.1),
          base.merge(ex_dividend_on: today.months_ago(6).strftime("%Y-%m-%d"), dividend: 0.1),
          base.merge(ex_dividend_on: today.months_ago(9).strftime("%Y-%m-%d"), dividend: 0.1),
          base.merge(ex_dividend_on: today.years_ago(1).strftime("%Y-%m-%d"), dividend: 0.01),
          base.merge(ex_dividend_on: today.years_ago(1).months_ago(3).strftime("%Y-%m-%d"), dividend: 0.01),
          base.merge(ex_dividend_on: today.years_ago(1).months_ago(6).strftime("%Y-%m-%d"), dividend: 0.01),
          base.merge(ex_dividend_on: today.years_ago(1).months_ago(9).strftime("%Y-%m-%d"), dividend: 0.01),
          base.merge(ex_dividend_on: today.years_ago(2).strftime("%Y-%m-%d"), dividend: 0.001),
          base.merge(ex_dividend_on: today.years_ago(2).months_ago(3).strftime("%Y-%m-%d"), dividend: 0.001),
          base.merge(ex_dividend_on: today.years_ago(2).months_ago(6).strftime("%Y-%m-%d"), dividend: 0.001),
          base.merge(ex_dividend_on: today.years_ago(2).months_ago(9).strftime("%Y-%m-%d"), dividend: 0.001),
        ]
      end

      it "12ヶ月分を一つの単位として集計した今年と昨年の配当情報を返す。集計基準日は配当落ち日" do
        actual = Tweet::Content::DividendReport.new.aggregate_by_12_months(dividends)
        expected = {
          trailing_twelve_months_ago: { annualized_dividend: 0.4, dividend_count: 4 },
          twelve_to_twenty_four_months_ago: { annualized_dividend: 0.04, dividend_count: 4 }
        }
        expect(actual).to eq expected
      end
    end
  end
end
