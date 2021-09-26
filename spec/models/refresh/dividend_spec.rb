# frozen_string_literal: true

require "rails_helper"

describe "Refresh::Dividend 配当情報を新規追加・削除する処理をまとめるクラス" do
  describe ".destroy_outdated レコード数削減のために一致期間以上前のレコードは削除する" do
    let!(:company) { FactoryBot.create(:company) }

    it "権利落ち日が2日以前の配当金は削除する" do
      FactoryBot.create(:dividend, :with_company, ex_dividend_date: Date.today.prev_day(2))
      FactoryBot.create(:dividend, :with_company, ex_dividend_date: Date.today.prev_day(1))
      expect { Refresh::Dividend.remove_outdated }.to change { Dividend.count }.by(-1)
      expect(Dividend.all.count).to eq 1
    end
  end

  describe ".update_us 米国株配当の新着情報を更新する" do
    it "US企業の新しいデータが追加される" do
      VCR.use_cassette("models/refresh/dividend/update_us") do
        expect { Refresh::Dividend.update_us(from: Date.parse("2021-09-02")) }.to change { Dividend.count }.by(421)
        expect(Company.first.symbol).to eq("AAN")
        expect(Company.last.symbol).to eq("ZTR")
        expect(Dividend.not_notified.count).to eq(421)
      end
      # もう一度実行しても新しく作成されない
      VCR.use_cassette("models/refresh/dividend/update_us_twice") do
        expect { Refresh::Dividend.update_us(from: Date.parse("2021-09-02")) }.to change { Dividend.count }.by(0)
      end
    end
  end

  describe ".refresh" do
    context "正常系" do
      let!(:symbols) { %w[CB ALB CINF TROW LEG KO] }
      let!(:target_start_date) { Date.new(2021, 9, 1) }

      it "シンボルと更新日以降の配当金情報が更新される。重複は無視する" do
        VCR.use_cassette("models/refresh/dividend/refresh") do
          expect { Refresh::Dividend.refresh(symbols: symbols, target_start_date: target_start_date) }
            .to change { Dividend.count }.by(6)
        end
        expect(Dividend.pluck(:symbol).uniq.sort).to eq symbols.sort
        VCR.use_cassette("models/refresh/dividend/refresh") do
          expect { Refresh::Dividend.refresh(symbols: symbols, target_start_date: target_start_date) }
            .to change { Dividend.count }.by(0)
        end
      end
    end
  end
end
