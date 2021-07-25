# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::Content::Dividend, type: :model do
  describe "#render_ex_dividend_previous_date" do
    context "初期テンプレート" do
      it "0件でツイート内容を作成して返す" do
        dividends = []
        workday = Workday.new(2021,1,1)
        content = Tweet::Content::Dividend.new(dividends: dividends, reference_date: workday)
        actual = content.ex_dividend_previous_date
        expected = "権利付き最終日通知\n#{workday.show}までの購入で配当金が受け取れる米国株は0件です"
        expect(actual).to eq(expected)
      end
    end

    context "規定文字数を超える情報が合った場合" do
      it "規定文字数を超えないようにツイート本文を作成して返す" do
        dividends = (1..100).map { |i| Dividend.new(symbol: "test#{i}") }
        workday = Workday.new(2021,1,1)
        content = Tweet::Content::Dividend.new(dividends: dividends, reference_date: workday)
        actual = content.ex_dividend_previous_date
        max_count = 25
        symbols_text = dividends[0..(max_count - 1)].map { |d| "$#{d[:symbol]}" }.join(" ")
        symbols_text += " ...残り#{dividends.count - max_count}件"
        expected = "権利付き最終日通知\n#{workday.show}までの購入で配当金が受け取れる米国株は#{dividends.count}件です\n#{symbols_text}"
        expect(actual).to eq(expected)
        expect(Twitter::TwitterText::Validation.parse_tweet(actual)[:valid]).to be true
      end
    end
  end

  describe "#render_symbols_part" do
    context "シンボルが規定文字数を超えない場合" do
      it "先頭に$を付けたシンボルを半角スペースで区切った文字列として返す" do
        expected = (1..20).map { |i| "$TEST#{i}" }.join(" ")
        dividends = (1..20).map { |i| Dividend.new(symbol: "TEST#{i}") }
        actual = Tweet::Content::Dividend.new(dividends: dividends).render_symbols_section
        expect(actual).to eq(expected)
      end
    end

    context "シンボルが規定文字数を超える場合" do
      it "規定文字列内で先頭に$を付けたシンボルを半角スペースで区切った文字列として返す" do
        symbols_string = (1..13).map { |i| "$TEST#{i}" }.join(" ")
        expected = "#{symbols_string} ...残り7件"
        dividends = (1..20).map { |i| Dividend.new(symbol: "TEST#{i}") }
        content = Tweet::Content::Dividend.new(dividends: dividends)
        actual = content.render_symbols_section(100)
        expect(actual).to eq(expected)

        # もう一度実行すると残りが取得できる
        expected = (14..20).map { |i| "$TEST#{i}" }.join(" ")
        actual = content.render_symbols_section(100)
        expect(actual).to eq(expected)
      end
    end
  end

  describe "#symbols_in_number_of_characters" do
    context "指定文字数を超えない場合" do
      it "シンボル文字列の配列を返す" do
        dividends = (1..5).map { |i| Dividend.new(symbol: "TEST#{i}") }
        expected = %w[TEST1 TEST2 TEST3 TEST4 TEST5]
        content = Tweet::Content::Dividend.new(dividends: dividends)
        actual = content.shift_symbols_in_number_of_characters(250)
        expect(actual).to eq expected
      end
    end

    context "指定文字数を超える場合" do
      it "シンボル文字列の配列を規定文字数を超えない範囲で返す" do
        dividends = (1..10).map { |i| Dividend.new(symbol: "TEST#{i}") }
        expected = %w[TEST1 TEST2 TEST3 TEST4]
        content = Tweet::Content::Dividend.new(dividends: dividends)
        actual = content.shift_symbols_in_number_of_characters(30)
        expect(actual).to eq expected

        expected = %w[TEST5 TEST6 TEST7 TEST8]
        actual = content.shift_symbols_in_number_of_characters(30)
        expect(actual).to eq expected
      end
    end
  end
end
