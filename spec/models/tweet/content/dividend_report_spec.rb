# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::Content::DividendReport, type: :model do
  describe "#new_dividend_of_dividend_aristocrats" do
    let!(:company) { FactoryBot.create(:company, symbol: "ADM", name: "Archer-Daniels-Midland Company", years_of_dividend_growth: 47) }
    let!(:dividend) { FactoryBot.create(:dividend, symbol: "ADM", company: company) }
    let!(:report_queue) { FactoryBot.create(:report_queue_of_dividend_aristocrats_dividend, dividend: dividend) }

    context "正常系" do
      it "tweets/new_dividend_of_dividend_aristocrats.text.erb から View をレンダリングして返す" do
        expected = <<~TWEET
          【配当貴族の $ADM に関する新着配当情報 #米国株】

          Archer-Daniels-Midland Company (連続増配 47年)
          セクター Consumer Defensive

          一株当たり配当 $0.37 (年間 $1.47)
          年間配当利回り 2.43%
          年間増配率 2.80% (+$0.04)
          配当性向 35.53%
          権利落ち日 2021-08-17
          配当支給日 2021-09-08
        TWEET

        VCR.use_cassette "models/tweet/content/dividend_report/new_dividend_of_dividend_aristocrats" do
          content = Tweet::Content::DividendReport.new
          text, image = content.new_dividend_of_dividend_aristocrats(report_queue.dividend.company, chart_start_on: Date.parse("2018-08-29"))
          expect(text).to eq expected
          expect(image).to be_instance_of File
        end
      end
    end
  end

  describe "#calculate_changed_dividend_and_its_rate_from_dividends" do
    let!(:today) { Date.today }
    let!(:base) do
      { ex_dividend_date: today.strftime("%Y-%m-%d"), record_date: today.tomorrow.strftime("%Y-%m-%d"),
        payment_date: today.next_week.strftime("%Y-%m-%d"), declaration_date: today.last_week.strftime("%Y-%m-%d"),
        dividend: 0.1, adjusted_dividend: 0.37, symbol: "ADM" }
    end
    let!(:dividends) do
      [
        base,
        base.merge(ex_dividend_date: today.months_ago(3).strftime("%Y-%m-%d"), dividend: 0.1),
        base.merge(ex_dividend_date: today.months_ago(6).strftime("%Y-%m-%d"), dividend: 0.1),
        base.merge(ex_dividend_date: today.months_ago(9).strftime("%Y-%m-%d"), dividend: 0.1),
        base.merge(ex_dividend_date: today.years_ago(1).strftime("%Y-%m-%d"), dividend: 0.01),
        base.merge(ex_dividend_date: today.years_ago(1).months_ago(3).strftime("%Y-%m-%d"), dividend: 0.01),
        base.merge(ex_dividend_date: today.years_ago(1).months_ago(6).strftime("%Y-%m-%d"), dividend: 0.01),
        base.merge(ex_dividend_date: today.years_ago(1).months_ago(9).strftime("%Y-%m-%d"), dividend: 0.01),
        base.merge(ex_dividend_date: today.years_ago(2).strftime("%Y-%m-%d"), dividend: 0.001),
        base.merge(ex_dividend_date: today.years_ago(2).months_ago(3).strftime("%Y-%m-%d"), dividend: 0.001),
        base.merge(ex_dividend_date: today.years_ago(2).months_ago(6).strftime("%Y-%m-%d"), dividend: 0.001),
        base.merge(ex_dividend_date: today.years_ago(2).months_ago(9).strftime("%Y-%m-%d"), dividend: 0.001),
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

    it "配当情報の dividend がないエッジパターン" do
      dividends = [
        base,
        base.merge(ex_dividend_date: today.months_ago(3).strftime("%Y-%m-%d"), dividend: nil, adjusted_dividend: 0.1),
        base.merge(ex_dividend_date: today.years_ago(1).strftime("%Y-%m-%d"), dividend: 0.1),
      ]
      actual = Tweet::Content::DividendReport.new.calculate_changed_dividend_and_its_rate_from_dividends(dividends)
      expected = {
        annualized_dividend: 0.2,
        changed_dividend: 0.1,
        changed_dividend_rate: 1,
      }
      expect(actual).to eq expected
    end
  end

  describe "#aggregate_by_12_months" do
    context "正常系-同じシンボルの過去の配当情報をDIVIDEND_CALENDAR形式の配列で取得した場合" do
      let!(:today) { Date.today }
      let!(:base) do
        { ex_dividend_date: today.strftime("%Y-%m-%d"), record_date: today.tomorrow.strftime("%Y-%m-%d"),
          payment_date: today.next_week.strftime("%Y-%m-%d"), declaration_date: today.last_week.strftime("%Y-%m-%d"),
          dividend: 0.1, adjusted_dividend: 0.37, symbol: "ADM" }
      end
      let!(:dividends) do
        [
          base,
          base.merge(ex_dividend_date: today.months_ago(3).strftime("%Y-%m-%d"), dividend: 0.1),
          base.merge(ex_dividend_date: today.months_ago(6).strftime("%Y-%m-%d"), dividend: 0.1),
          base.merge(ex_dividend_date: today.months_ago(9).strftime("%Y-%m-%d"), dividend: 0.1),
          base.merge(ex_dividend_date: today.years_ago(1).strftime("%Y-%m-%d"), dividend: 0.01),
          base.merge(ex_dividend_date: today.years_ago(1).months_ago(3).strftime("%Y-%m-%d"), dividend: 0.01),
          base.merge(ex_dividend_date: today.years_ago(1).months_ago(6).strftime("%Y-%m-%d"), dividend: 0.01),
          base.merge(ex_dividend_date: today.years_ago(1).months_ago(9).strftime("%Y-%m-%d"), dividend: 0.01),
          base.merge(ex_dividend_date: today.years_ago(2).strftime("%Y-%m-%d"), dividend: 0.001),
          base.merge(ex_dividend_date: today.years_ago(2).months_ago(3).strftime("%Y-%m-%d"), dividend: 0.001),
          base.merge(ex_dividend_date: today.years_ago(2).months_ago(6).strftime("%Y-%m-%d"), dividend: 0.001),
          base.merge(ex_dividend_date: today.years_ago(2).months_ago(9).strftime("%Y-%m-%d"), dividend: 0.001),
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
          { ex_dividend_date: "2021-08-10", dividend: 0.1 },
          { ex_dividend_date: "2020-09-01", dividend: 0.1 },
          # 過去12-24ヶ月前の配当
          { ex_dividend_date: "2020-08-31", dividend: 0.01 },
          { ex_dividend_date: "2019-09-01", dividend: 0.01 },
          # 24-36ヶ月前 (集計外)
          { ex_dividend_date: "2019-08-31", dividend: 0.001 },
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
