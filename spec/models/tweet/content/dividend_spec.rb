# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::Content::Dividend, type: :model do
  describe "render_ex_dividend_previous_date" do
    context "引数に空の配列を渡された場合" do
      it "0件でツイート内容を作成して返す" do
        dividends = []
        expected = "今日までの購入で配当金が受け取れる米国株は「0件」です (配当落ち前日)"
        content = Tweet::Content::Dividend.new(dividends: dividends)
        actual = content.ex_dividend_previous_date
        expect(actual).to eq(expected)
      end
    end

    context "引数に:symbolのキーを持つオブジェクトを渡された場合" do
      it "オブジェクトの個数と:symbolの値からツイート本文を作成して返す" do
        dividends = [
          Dividend.new(symbol: "test"),
          Dividend.new(symbol: "dividend"),
          Dividend.new(symbol: "portal"),
        ]
        symbols_text = dividends.map { |d| "$#{d[:symbol]}" }.join(" ")
        expected = "今日までの購入で配当金が受け取れる米国株は「#{dividends.count}件」です (配当落ち前日)\n#{symbols_text}\n"
        content = Tweet::Content::Dividend.new(dividends: dividends)
        actual = content.ex_dividend_previous_date
        expect(actual).to eq(expected)
      end
    end

    context "引数に:symbolのキーを持つオブジェクトを渡されてツイート本文が規定文字数を超える場合" do
      it "規定文字数を超えないようにツイート本文を作成して返す" do
        dividends = (1..100).map { |i| Dividend.new(symbol: "test#{i}") }
        max_count = 22
        symbols_text = dividends[0..(max_count - 1)].map { |d| "$#{d[:symbol]}" }.join(" ")
        symbols_text += " ...残り#{dividends.count - max_count}件"
        expected = <<~TWEET
          今日までの購入で配当金が受け取れる米国株は「#{dividends.count}件」です (配当落ち前日)
          #{symbols_text}
        TWEET
        content = Tweet::Content::Dividend.new(dividends: dividends)
        actual = content.ex_dividend_previous_date
        expect(actual).to eq(expected)
        expect(Twitter::TwitterText::Validation.parse_tweet(actual)[:valid]).to be true
      end
    end
  end

  describe ".symbols_in_number_of_characters" do
    context "指定文字数を超えない場合" do
      it "シンボル文字列の配列を返す" do
        dividends = (1..5).map { |i| Dividend.new(symbol: "TEST#{i}") }
        expected = %w[TEST1 TEST2 TEST3 TEST4 TEST5]
        content = Tweet::Content::Dividend.new(dividends: dividends)
        actual = content.shift_symbols_in_number_of_characters("", 250)
        expect(actual).to eq expected
      end
    end

    context "指定文字数を超える場合" do
      it "シンボル文字列の配列を規定文字数を超えない範囲で返す" do
        dividends = (1..10).map { |i| Dividend.new(symbol: "TEST#{i}") }
        expected = %w[TEST1 TEST2 TEST3 TEST4]
        content = Tweet::Content::Dividend.new(dividends: dividends)
        actual = content.shift_symbols_in_number_of_characters("", 30)
        expect(actual).to eq expected

        expected = %w[TEST5 TEST6 TEST7 TEST8]
        actual = content.shift_symbols_in_number_of_characters("", 30)
        expect(actual).to eq expected
      end
    end
  end
end
