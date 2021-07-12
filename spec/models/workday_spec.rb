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

  describe "#next_workday" do
    context "翌日が営業日の場合" do
      it "翌日=営業日をWorkdayクラスで返す" do
        actual = Workday.new(2021, 7, 12).next_workday(:us) # 2021/7/12は月曜日
        expected = Workday.new(2021, 7, 13) # 火曜日。祝日ではない
        expect(actual).to eq(expected)
      end
    end

    context "翌日が週末の場合" do
      it "休日明けの営業日をWorkdayクラスで返す" do
        actual = Workday.new(2021, 7, 3).next_workday(:us) # 2021/7/3は土曜日
        expected = Workday.new(2021, 7, 5) # 月曜日。祝日ではない
        expect(actual).to eq(expected)
      end
    end

    context "翌日が祝日の場合" do
      it "祝日明けの営業日をWorkdayクラスで返す" do
        actual = Workday.new(2021, 11, 10).next_workday(:us) # 2021/11/11木曜日は"Veterans Day"で祝日
        expected = Workday.new(2021, 11, 12) # 金曜日
        expect(actual).to eq(expected)
      end
    end

    context "休日と祝日が複合している場合" do
      it "翌営業日をWorkdayクラスで返す" do
        actual = Workday.new(2021, 1, 15).next_workday(:us) # 2021/1/18月曜は"Martin Luther King, Jr. Day"で祝日
        expected = Workday.new(2021, 1, 19) # 火曜日
        expect(actual).to eq(expected)
      end
    end
  end
end
