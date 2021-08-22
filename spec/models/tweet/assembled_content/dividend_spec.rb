# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::AssembledContent::Dividend, type: :model do
  describe "#render_ex_dividend_previous_date" do
    context "初期テンプレート" do
      let!(:dividends) { [] }
      let!(:workday) { Workday.new(2021, 1, 1) }
      let!(:content) { Tweet::AssembledContent::Dividend.new(dividends: dividends, reference_date: workday) }

      it "0件でツイート内容を作成して返す" do
        actual = content.ex_dividend_previous_date
        expected = "権利付き最終日通知\n#{workday.show}までの購入で配当金が受け取れる米国株は0件です"
        expect(actual).to eq(expected)
      end
    end

    context "規定文字数を超える情報が合った場合" do
      let!(:dividends) { (1..100).map { |i| Dividend.new(symbol: "test#{i}") } }
      let!(:workday) { Workday.new(2021, 1, 1) }
      let!(:content) { Tweet::AssembledContent::Dividend.new(dividends: dividends, reference_date: workday) }
      let!(:symbols_text) do
        max_count = 25
        dividends[0..(max_count - 1)].map { |d| "$#{d[:symbol]}" }.join(" ") + " ...残り#{dividends.count - max_count}件"
      end

      it "規定文字数を超えないようにツイート本文を作成して返す" do
        actual = content.ex_dividend_previous_date
        expected = "権利付き最終日通知\n#{workday.show}までの購入で配当金が受け取れる米国株は#{dividends.count}件です\n#{symbols_text}"
        expect(actual).to eq(expected)
        expect(Twitter::TwitterText::Validation.parse_tweet(actual)[:valid]).to be true
      end
    end
  end

  describe "#remained_symbols" do
    context "シンボルが規定文字数を超える場合" do
      let!(:dividends) { (1..70).map { |i| Dividend.new(symbol: "TEST#{i}") } }
      let!(:content) { Tweet::AssembledContent::Dividend.new(dividends: dividends) }

      it "残ったシンボルを順次書き出しする" do
        # 一度書き出す
        content.ex_dividend_previous_date

        symbols_string = (26..58).map { |i| "$TEST#{i}" }.join(" ")
        expected = "#{symbols_string} ...残り12件"
        actual = content.remained_symbols
        expect(actual).to eq(expected)

        expected = (59..70).map { |i| "$TEST#{i}" }.join(" ")
        actual = content.remained_symbols
        expect(actual).to eq(expected)
      end
    end
  end

  describe "#render_symbols_part" do
    context "シンボルが規定文字数を超えない場合" do
      it "先頭に$を付けたシンボルを半角スペースで区切った文字列として返す" do
        expected = (1..20).map { |i| "$TEST#{i}" }.join(" ")
        dividends = (1..20).map { |i| Dividend.new(symbol: "TEST#{i}") }
        actual = Tweet::AssembledContent::Dividend.new(dividends: dividends).render_symbols_section
        expect(actual).to eq(expected)
      end
    end

    context "シンボルが規定文字数を超える場合" do
      let!(:dividends) { (1..100).map { |i| Dividend.new(symbol: "TEST#{i}") } }
      let!(:content) { Tweet::AssembledContent::Dividend.new(dividends: dividends) }

      it "規定文字列内で先頭に$を付けたシンボルを半角スペースで区切った文字列として返す" do
        symbols_string = (1..34).map { |i| "$TEST#{i}" }.join(" ")
        expected = "#{symbols_string} ...残り66件"
        actual = content.render_symbols_section
        expect(actual).to eq(expected)

        # もう一度実行すると残りが取得できる
        symbols_string = (35..67).map { |i| "$TEST#{i}" }.join(" ")
        expected = "#{symbols_string} ...残り33件"
        actual = content.render_symbols_section
        expect(actual).to eq(expected)
      end
    end
  end

  describe "#symbols_in_number_of_characters" do
    context "指定文字数を超えない場合" do
      it "シンボル文字列の配列を返す" do
        dividends = (1..5).map { |i| Dividend.new(symbol: "TEST#{i}") }
        expected = %w[TEST1 TEST2 TEST3 TEST4 TEST5]
        content = Tweet::AssembledContent::Dividend.new(dividends: dividends)
        actual = content.shift_symbols_in_number_of_characters(250)
        expect(actual).to eq expected
      end
    end

    context "指定文字数を超える場合" do
      it "シンボル文字列の配列を規定文字数を超えない範囲で返す" do
        dividends = (1..10).map { |i| Dividend.new(symbol: "TEST#{i}") }
        expected = %w[TEST1 TEST2 TEST3 TEST4]
        content = Tweet::AssembledContent::Dividend.new(dividends: dividends)
        actual = content.shift_symbols_in_number_of_characters(30)
        expect(actual).to eq expected

        expected = %w[TEST5 TEST6 TEST7 TEST8]
        actual = content.shift_symbols_in_number_of_characters(30)
        expect(actual).to eq expected
      end
    end
  end
end
