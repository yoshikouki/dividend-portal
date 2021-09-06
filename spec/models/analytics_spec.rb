# frozen_string_literal: true

require "rails_helper"

describe "Analytics 検証用の分析モデル" do
  describe ".dividend_growth_rate" do
    it "配当貴族の増配率を網羅的に取得する" do
      VCR.use_cassette("models/analytics/dividend_growth_rate") do
        analytics = Analytics.dividend_growth_rate
        expect(analytics.resource.count).to eq(65)
        expect(analytics.latest_dividend_growth.count).to eq(65)
      end
    end
  end
end
