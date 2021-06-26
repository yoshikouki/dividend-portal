# frozen_string_literal: true

require "rails_helper"

RSpec.describe Client, type: :model do
  describe "value_to_time" do
    context "Hash の value が文字列だった場合" do
      it "value を %Y-%m-%d の形式に変換して返す" do
        cases = [
          {
            from: "2021-01-01",
            to: "2021-12-31",
          },
          {
            from: "20210101",
            to: "20211231",
          },
          {
            from: "210101",
            to: "211231",
          },
        ]
        expect = {
          from: "2021-01-01",
          to: "2021-12-31",
        }
        cases.each do |c|
          expect(Client.value_to_time(c)).to eq(expect)
        end
      end
    end

    context "Hash の value が Time インスタンスだった場合" do
      it "インスタンスを %Y-%m-%d の形式に変換して返す" do
        cases = [
          {
            from: Time.parse("2021-01-01"),
            to: Time.parse("2021-12-31"),
          },
        ]
        expect = {
          from: "2021-01-01",
          to: "2021-12-31",
        }
        cases.each do |c|
          expect(Client.value_to_time(c)).to eq(expect)
        end
      end
    end
  end
end
