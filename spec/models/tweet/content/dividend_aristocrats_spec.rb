# frozen_string_literal: true

require "rails_helper"

describe "Tweet::Content::DividendAristocrats" do
  describe "#ranking_of_weekly_price_drop_rate" do
    let!(:reference_date) { Date.new(2021, 9, 4) } # 土曜日

    before do
      VCR.use_cassette("models/refresh/dividend_aristocrat/prices") do
        Refresh::DividendAristocrat.weekly_prices(reference_date: reference_date)
      end
    end

    context "正常系" do
      let!(:expected_content) do
        <<~TWEET
          【配当貴族の週足値下がりランキング 2021-09-04 #米国株】

          1. ABBV (-6.86%)
          2. NUE (-5.83%)
          3. HRL (-4.55%)
          4. PPG (-4.43%)
          5. LEG (-3.83%)

          ↓ 今週最も値下がりした銘柄の週足ラインチャート
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
end
