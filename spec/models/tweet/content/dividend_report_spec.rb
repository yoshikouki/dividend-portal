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

      it "tweets/new_dividend_of_dividend_aristocrats.text.erb から View をレンダリングして返す" do
        allow(Client::Fmp).to receive(:historical_dividends).and_return(historical_dividends_response)
        allow(Client::Fmp).to receive(:company_outlook).and_return(company_outlook_response)
        actual = Tweet::Content::DividendReport.new.new_dividend_of_dividend_aristocrats(report_queue)
        expected = <<~TWEET
          #配当貴族 $ADM の新着配当金情報です

          Archer-Daniels-Midland Company (連続増配 47年)
          年間配当利回り 2.28%
          年間増配率 2.80% ($0.04)
          一株当たり配当 $0.37 (年間 $4.09)
          配当性向 60.60%
          権利落ち日 2021-08-17
          配当支給日 2021-09-08
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

      it "12ヶ月分を一つの単位として集計した今年と昨年の配当情報を返す。集計基準日は配当落ち日の月初日" do
        actual = Tweet::Content::DividendReport.new.aggregate_by_12_months(dividends)
        expected = {
          trailing_twelve_months_ago: { annualized_dividend: 0.4, dividend_count: 4 },
          twelve_to_twenty_four_months_ago: { annualized_dividend: 0.04, dividend_count: 4 },
        }
        expect(actual).to eq expected
      end
    end

    context "集計基準日の配当落ち日に揺れがあった場合" do
      let!(:reference_date) { Date.new(2021, 8, 10) }
      let!(:dividends) do
        [
          # 2021年8月10日に配当支払いがあった場合、2020年9月1日以降の配当を過去12ヶ月分と計算する
          { ex_dividend_on: "2021-08-10", dividend: 0.1 },
          { ex_dividend_on: "2020-09-01", dividend: 0.1 },
          # 過去12-24ヶ月前の配当
          { ex_dividend_on: "2020-08-31", dividend: 0.01 },
          { ex_dividend_on: "2019-09-01", dividend: 0.01 },
          # 24-36ヶ月前 (集計外)
          { ex_dividend_on: "2019-08-31", dividend: 0.001 },
        ]
      end

      it "12ヶ月をひとまとまりとして集計される" do
        actual = Tweet::Content::DividendReport.new.aggregate_by_12_months(dividends, reference_date: reference_date)
        expected = {
          trailing_twelve_months_ago: { annualized_dividend: 0.2, dividend_count: 2 },
          twelve_to_twenty_four_months_ago: { annualized_dividend: 0.02, dividend_count: 2 },
        }
        expect(actual).to eq expected
      end
    end
  end
end