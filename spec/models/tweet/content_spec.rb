# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::Content, type: :model do
  describe ".symbols_in_number_of_characters" do
    context "指定文字数を超えない場合" do
      it "先頭に$を付けたシンボル文字列の配列を返す" do
        dividends = (1..5).map { |i| Dividend.new(symbol: "TEST#{i}") }
        expected = %w[$TEST1 $TEST2 $TEST3 $TEST4 $TEST5]
        actual = Tweet::Content.symbols_in_number_of_characters(dividends, "", 250)
        expect(actual).to eq expected
      end
    end

    context "指定文字数を超える場合" do
      it "先頭に$を付けたシンボル文字列の配列を規定文字数を超えない範囲で返す" do
        dividends = (1..5).map { |i| Dividend.new(symbol: "TEST#{i}") }
        expected = %w[$TEST1 $TEST2 $TEST3 $TEST4]
        actual = Tweet::Content.symbols_in_number_of_characters(dividends, "", 30)
        expect(actual).to eq expected
      end
    end
  end
end
