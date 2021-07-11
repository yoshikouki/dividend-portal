# frozen_string_literal: true

require "rails_helper"

RSpec.describe Workday, type: :model do
  describe "#holiday?" do
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

  describe "#holiday" do
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

  describe "#workday?" do
    context "引数が空の場合" do
      it "国はUSとして営業日だったら true を返す" do
        independence_day = Workday.new(2021, 7, 4)
        actual = independence_day.workday?
        expect(actual).to be false
      end
    end

    context "引数に国のシンボルが渡された場合" do
      it "その国の祝日で判定する" do
        king_jr_day = Workday.new(2021, 1, 18)
        expect(king_jr_day.workday?(:us)).to be false
        expect(king_jr_day.workday?(:jp)).to be true
      end

      it "週末じゃなくても祝日なら false" do
        new_year_day = Workday.new(2021, 1, 1)
        expect(new_year_day.on_weekday?).to be true
        expect(new_year_day.workday?(:us)).to be false
      end
    end
  end

  describe ".next_workday" do
    context "翌日が営業日の場合" do
      it "翌日=営業日をWorkdayクラスで返す" do
        expected = Workday.new(2021, 7, 5)        # 月曜日。祝日ではない
        reference_day = Workday.new(2021, 7, 3)   # 土曜日
        actual = Workday.next_workday(:jp, reference_day)
        expect(actual).to eq(expected)
      end
    end
    context "翌日が休日の場合" do
      it "休日明けの営業日をWorkdayクラスで返す" do
        expected = Workday.new(2021, 7, 5)        # 月曜日。祝日ではない
        reference_day = Workday.new(2021, 7, 3)   # 土曜日
        actual = Workday.next_workday(:jp, reference_day)
        expect(actual).to eq(expected)
      end
    end
  end
end
