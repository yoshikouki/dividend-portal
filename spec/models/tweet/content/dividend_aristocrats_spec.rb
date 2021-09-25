# frozen_string_literal: true

require "rails_helper"

describe "Tweet::Content::DividendAristocrats" do
  describe "#ranking_of_weekly_price_drop_rate" do
    let!(:reference_date) { Date.new(2021, 9, 25) }

    before do
      VCR.use_cassette "models/tweet/content/dividend_aristocrats/ranking_of_weekly_price_drop_rate" do
        Refresh::DividendAristocrat.weekly_prices(reference_date: reference_date)
      end
    end

    context "正常系" do
      let!(:expected_content) do
        <<~TWEET
          【配当貴族の週足値下がりランキング #米国株】

          1. HRL (-2.83%)
          2. BDX (-2.40%)
          3. ADM (-2.27%)
          4. CAH (-1.56%)
          5. WBA (-1.55%)

          ↓ 今週最も値下がりした銘柄の週足ラインチャート
        TWEET
      end

      it "週足値下がりランキングのコンテンツとチャート画像のパスを配列で返す" do
        text, chart_path = Tweet::Content::DividendAristocrats.new.ranking_of_weekly_price_drop_rate(reference_date: reference_date)
        expect(text).to eq expected_content
        expect(chart_path).to eq "prices_chart_path"
      end
    end
  end
end
