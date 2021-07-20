# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dividend::Recent, type: :model do
  valid_params = {
    ex_dividend_on: "2020-08-07",
    records_on: "2020-08-10",
    pays_on: "2020-09-10",
    declares_on: "2020-07-28",
    symbol: "IBM",
    dividend: 1.63,
    adjusted_dividend: 1.63,
  }

  describe "validates" do
    it "正しい" do
      dividend = Dividend::Recent.new(valid_params)
      expect(dividend.valid?).to be true
    end
  end

  describe ".update_to_latest" do
    let!(:dividend) { FactoryBot.create(:dividend) }

    it "新しいデータが追加される" do
      latest_dividends = [
        dividend,
        Dividend.new(
          ex_dividend_on: Date.today,
          records_on: Date.tomorrow,
          pays_on: Date.today.next_month,
          declares_on: Date.today.last_month,
          symbol: "AZZ",
          dividend: 0.1,
          adjusted_dividend: 0.1,
        ),
      ]
      expect { Dividend::Recent.update_to_latest(latest_dividends) }.to change { Dividend.count }.by(1)
    end
  end

  describe ".destroy_outdated" do
    it "権利落ち日が3日以前の配当金は削除する" do
      FactoryBot.create(
        :dividend,
        ex_dividend_on: Date.today.prev_day(3),
      )
      FactoryBot.create(
        :dividend,
        ex_dividend_on: Date.today.prev_day(2),
      )
      expect { Dividend::Recent.destroy_outdated }.to change { Dividend.count }.by(-1)
      expect(Dividend.all.count).to eq 1
    end
  end
end
