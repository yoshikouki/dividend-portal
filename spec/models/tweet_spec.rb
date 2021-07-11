# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet, type: :model do
  describe "render_ex_dividend_previous_date" do
    context "引数に空の配列を渡された場合" do
      it "0件でツイート内容を作成して返す" do
        dividends = []
        expected = "今日までの購入で配当金が受け取れる米国株は「0件」です (配当落ち前日)\n"
        actual = Tweet.render_ex_dividend_previous_date(dividends)
        expect(actual).to eq(expected)
      end
    end

    context "引数に:symbolのキーを持つオブジェクトを渡された場合" do
      it "オブジェクトの個数と:symbolの値からツイート本文を作成して返す" do
        dividends = [
          { symbol: "test" },
          { symbol: "dividend" },
          { symbol: "portal" },
        ]
        symbols_text = dividends.map { |d| "$#{d[:symbol]}" }.join(" ")
        expected = "今日までの購入で配当金が受け取れる米国株は「#{dividends.count}件」です (配当落ち前日)\n#{symbols_text} "
        actual = Tweet.render_ex_dividend_previous_date(dividends)
        expect(actual).to eq(expected)
      end
    end
  end
end
