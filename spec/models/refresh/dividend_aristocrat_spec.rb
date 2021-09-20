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

  describe ".weekly_prices 配当貴族の株価を一週間単位で更新する" do
    it "基準日 (実行日がデフォルト) が属する週の月曜から金曜までの株価を prices テーブルに追加する" do
      VCR.use_cassette("models/refresh/dividend_aristocrat/prices") do
        expect { Refresh::DividendAristocrat.weekly_prices(reference_date: Date.new(2021, 9, 1)) }.to change { Price.count }.by(325)
        expect(Price.order(:date).first.date).to eq Date.new(2021, 8, 30)
        expect(Price.order(:date).last.date).to eq Date.new(2021, 9, 3)
        expect { Refresh::DividendAristocrat.weekly_prices(reference_date: Date.new(2021, 9, 1)) }.to change { Price.count }.by(0)
      end
    end
  end
end
