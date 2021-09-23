# frozen_string_literal: true

require "rails_helper"

describe "WeeklyPrice" do
  describe ".find_by_symbol_and_date" do
    let!(:last_friday) { FactoryBot.create(:price, date: "2021-09-10", symbol: "TEST") }
    let!(:this_monday) { FactoryBot.create(:price, date: "2021-09-13", symbol: "TEST") }
    let!(:this_friday) { FactoryBot.create(:price, date: "2021-09-17", symbol: "TEST") }
    let!(:next_monday) { FactoryBot.create(:price, date: "2021-09-20", symbol: "TEST") }

    it "引数のシンボルとDateから週足の株価を計算してインスタンスを返す" do
      target_date = Date.new(2021, 9, 15)
      weekly_price = WeeklyPrice.find_by_symbol_and_date("TEST", target_date)
      expect(weekly_price).to be_instance_of WeeklyPrice
      expect(weekly_price.daily_prices).to eq [this_monday, this_friday]
      expect(weekly_price.symbol).to eq "TEST"
      expect(weekly_price.date).to eq target_date.monday
      expect(weekly_price.open).to eq 10
      expect(weekly_price.close).to eq 20
      expect(weekly_price.adjusted_close).to eq 20
      expect(weekly_price.high).to eq 20
      expect(weekly_price.low).to eq 1
      expect(weekly_price.volume).to eq 200
      expect(weekly_price.change).to eq 10
      expect(weekly_price.change_percent).to eq 100
    end
  end
end
