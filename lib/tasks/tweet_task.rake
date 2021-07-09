# frozen_string_literal: true

namespace :tweet do
  desc "権利落ち前日の米国株を配信する"
  task ex_dividend_previous_date: :environment do
    tomorrow = Time.at(1.day.since).strftime("%Y-%m-%d")
    dividends = Client::Fmp.get_dividend_calendar(from: tomorrow, to: tomorrow)

    # ツイート文面を作成
    symbols_text = dividends.map { |dividend| "$#{dividend[:symbol]}" }.sort.join(" ")

    # ツイート
    tweet_text = Tweet.render_ex_dividend_previous_date(dividends.count, symbols_text)
    Tweet.tweet(tweet_text)
  end
end
