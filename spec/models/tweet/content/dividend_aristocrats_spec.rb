# frozen_string_literal: true

require "rails_helper"

describe "Tweet::Content::DividendAristocrats" do
  describe "#ranking_of_weekly_price_drop_rate" do
    let!(:reference_date) { Date.new(2021, 9, 4) } # 土曜日

    before do
      VCR.use_cassette("models/refresh/dividend_aristocrat/prices") do
        Refresh::DividendAristocrat.weekly_prices(reference_date: reference_date)
      end
      FactoryBot.create(:dividend, symbol: "ABBV", dividend: 5.08, ex_dividend_date: reference_date)
      FactoryBot.create(:dividend, symbol: "NUE", dividend: 1.618, ex_dividend_date: reference_date)
      FactoryBot.create(:dividend, symbol: "HRL", dividend: 0.9675, ex_dividend_date: reference_date)
      FactoryBot.create(:dividend, symbol: "PPG", dividend: 2.21, ex_dividend_date: reference_date)
      FactoryBot.create(:dividend, symbol: "LEG", dividend: 1.64, ex_dividend_date: reference_date)
    end

    context "正常系" do
      let!(:expected_content) do
        <<~TWEET
          【今週の値下がりランキング #配当貴族 #米国株】

          1. $ABBV (-6.9%, 配当利回 4.6%)
          2. $NUE (-5.8%, 配当利回 1.4%)
          3. $HRL (-4.5%, 配当利回 2.3%)
          4. $PPG (-4.4%, 配当利回 1.4%)
          5. $LEG (-3.8%, 配当利回 3.4%)

          📈最下位の年間チャート📉
        TWEET
      end

      it "週足値下がりランキングのコンテンツとチャート画像のパスを配列で返す" do
        VCR.use_cassette "models/tweet/content/dividend_aristocrats/ranking_of_weekly_price_drop_rate" do
          text, chart = Tweet::Content::DividendAristocrats.new.ranking_of_weekly_price_drop_rate(reference_date: reference_date)
          expect(text).to eq expected_content
          expect(chart).to be_an_instance_of File
        end
      end
    end
  end

  describe "#ranking_of_daily_price_changing_rate" do
    let!(:reference_date) { Date.new(2021, 9, 3) } # 土曜日

    before do
      VCR.use_cassette("models/refresh/dividend_aristocrat/prices") do
        Refresh::DividendAristocrat.weekly_prices(reference_date: reference_date)
        FactoryBot.create(:dividend, symbol: "BF-B", dividend: 0.18, ex_dividend_date: reference_date.yesterday)
        FactoryBot.create(:dividend, symbol: "ABBV", dividend: 5.08, ex_dividend_date: reference_date.yesterday)
        FactoryBot.create(:dividend, symbol: "HRL", dividend: 0.9675, ex_dividend_date: reference_date.yesterday)
        FactoryBot.create(:dividend, symbol: "T", dividend: 2.08, ex_dividend_date: reference_date.yesterday)
        FactoryBot.create(:dividend, symbol: "CAH", dividend: 1.4628, ex_dividend_date: reference_date.yesterday)
        FactoryBot.create(:dividend, symbol: "WBA", dividend: 1.8795000000000002, ex_dividend_date: reference_date.yesterday)
      end
    end

    context "正常系" do
      let!(:expected_content) do
        <<~TWEET
          【配当貴族の日足変化率ランキング 9/2 #米国株】

          ⏬下位
          1. $BF-B (-2.0%, 配当利回 0.3%)
          2. $ABBV (-1.3%, 配当利回 4.5%)
          3. $HRL (-1.2%, 配当利回 2.2%)

          ⏫上位
          1. $WBA (2.5%, 配当利回 3.6%)
          2. $CAH (2.2%, 配当利回 2.7%)
          3. $T (1.7%, 配当利回 7.5%)

          ↓最下位チャート↓
        TWEET
      end

      it "日足の値下がりランキングのテキストコンテンツとチャート画像のパスを配列で返す" do
        VCR.use_cassette "models/tweet/content/dividend_aristocrats/ranking_of_daily_price_changing_rate" do
          text, chart = Tweet::Content::DividendAristocrats.new.ranking_of_daily_price_changing_rate(reference_date: reference_date)
          expect(text).to eq expected_content
          expect(chart).to be_an_instance_of File
        end
      end
    end
  end
end
