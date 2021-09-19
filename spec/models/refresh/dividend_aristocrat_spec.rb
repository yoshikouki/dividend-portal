# frozen_string_literal: true

require "rails_helper"

describe "Refresh::DividendAristocrat 配当貴族の情報を更新する" do
  describe ".general 配当貴族に関する情報を最新にする" do
    it "情報がなかった場合、新しく作られる" do
      VCR.use_cassette("models/refresh/dividend_aristocrat/general") do
        expect { Refresh::DividendAristocrat.general }
          .to change { Dividend.count }.by(10_639)
                                       .and change { Company.count }.by(65)
                                                                    .and change { StockSplit.count }.by(364)
      end
    end
  end

  describe ".prices 配当貴族の株価を更新する" do
    it "情報がなかった場合、新しく作られる" do
      VCR.use_cassette("models/refresh/dividend_aristocrat/prices") do
        expect { Refresh::DividendAristocrat.prices }.to change { Price.count }.by(325)
      end
    end
  end
end
