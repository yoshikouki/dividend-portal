# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet, type: :model do
  describe "render_ex_dividend_previous_date" do
    context "引数に空の配列を渡された場合" do
      it "0件でツイート内容を作成して返す" do
        dividends = []
        expected = "今日までの購入で配当金が受け取れる米国株は「0件」です (配当落ち前日)"
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
        expected = "今日までの購入で配当金が受け取れる米国株は「#{dividends.count}件」です (配当落ち前日)\n#{symbols_text}\n"
        actual = Tweet.render_ex_dividend_previous_date(dividends)
        expect(actual).to eq(expected)
      end
    end

    context "引数に:symbolのキーを持つオブジェクトを渡されてツイート本文が規定文字数を超える場合" do
      it "規定文字数を超えないようにツイート本文を作成して返す" do
        dividends = (1..100).map { |i| { symbol: "test#{i}" } }
        max_count = 22
        symbols_text = dividends[0..(max_count - 1)].map { |d| "$#{d[:symbol]}" }.join(" ")
        symbols_text += "...他#{dividends.count - max_count}件"
        expected = <<~TWEET
          今日までの購入で配当金が受け取れる米国株は「#{dividends.count}件」です (配当落ち前日)
          #{symbols_text}
        TWEET
        actual = Tweet.render_ex_dividend_previous_date(dividends)
        expect(actual).to eq(expected)
        expect(Twitter::TwitterText::Validation.parse_tweet(actual)[:valid]).to be true
      end
    end
  end
end
