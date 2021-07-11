# frozen_string_literal: true

require "rails_helper"

RSpec.describe Workday, type: :model do
  describe "holiday?" do
    context "引数が空の場合" do
      it "登録されている全ての国で祝日を判定する" do
        actual = Workday.new(2021, 1, 1).holiday?
        expect(actual).to be true
      end
    end

    context "引数に国のシンボルが渡された場合" do
      it "その国の祝日で判定する" do
        national_foundation_day_of_jp = Workday.new(2021, 2, 11)
        expect(national_foundation_day_of_jp.holiday?(:jp)).to be true
        expect(national_foundation_day_of_jp.holiday?(:us)).to be false
      end
    end
  end

  describe "holiday" do
    context "引数が空の場合" do
      it "登録されている全ての国で祝日を判定する" do
        actual = Workday.new(2021, 1, 1).holiday
        expect(actual.count).to be > 1
      end
    end

    context "引数に国のシンボルが渡された場合" do
      it "その国の祝日で判定する" do
        national_foundation_day_of_jp = Workday.new(2021, 2, 11)
        expect(national_foundation_day_of_jp.holiday(:jp)).to eq([{ date: national_foundation_day_of_jp, name: "建国記念の日", regions: [:jp] }])
        expect(national_foundation_day_of_jp.holiday(:us)).to eq([])
      end
    end
  end
end
