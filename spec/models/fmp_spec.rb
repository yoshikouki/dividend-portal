# frozen_string_literal: true

require "rails_helper"

describe "Fmp 企業や株に関する情報を API 経由で取得することを責務にする" do
  require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

  describe ".financial_growth 企業に関する各種項目の成長率を会計年度・四半期毎に取得する" do
    let!(:expected_keys) {
      [:symbol,
       :date,
       :period,
       :revenue_growth,
       :gross_profit_growth,
       :ebitgrowth,
       :operating_income_growth,
       :net_income_growth,
       :epsgrowth,
       :epsdiluted_growth,
       :weighted_average_shares_growth,
       :weighted_average_shares_diluted_growth,
       :dividendsper_share_growth,
       :operating_cash_flow_growth,
       :free_cash_flow_growth,
       :ten_y_revenue_growth_per_share,
       :five_y_revenue_growth_per_share,
       :three_y_revenue_growth_per_share,
       :ten_y_operating_cf_growth_per_share,
       :five_y_operating_cf_growth_per_share,
       :three_y_operating_cf_growth_per_share,
       :ten_y_net_income_growth_per_share,
       :five_y_net_income_growth_per_share,
       :three_y_net_income_growth_per_share,
       :ten_y_shareholders_equity_growth_per_share,
       :five_y_shareholders_equity_growth_per_share,
       :three_y_shareholders_equity_growth_per_share,
       :ten_y_dividendper_share_growth_per_share,
       :five_y_dividendper_share_growth_per_share,
       :three_y_dividendper_share_growth_per_share,
       :receivables_growth,
       :inventory_growth,
       :asset_growth,
       :book_valueper_share_growth,
       :debt_growth,
       :rdexpense_growth,
       :sgaexpenses_growth]
    }
    context "会計年度別 (デフォルト)" do
      it "取得できる" do
        VCR.use_cassette("models/fmp/financial_growth") do
          actual = Fmp.financial_growth("KO")
          expect(actual.class).to eq Array
          expect(actual[0].keys).to eq expected_keys
        end
      end
    end

    context "四半期毎" do
      it "取得できる" do
        VCR.use_cassette("models/fmp/financial_growth_quarter") do
          actual = Fmp.financial_growth("KO", period: :quarter)
          expect(actual.class).to eq Array
          expect(actual[0].keys).to eq expected_keys
        end
      end
    end
  end
end
