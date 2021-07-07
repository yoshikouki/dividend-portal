# frozen_string_literal: true

namespace :tweet do
  desc "権利落ち前日の米国株を配信する"
  task :ex_dividend_previous_date do
    require "../../app/models/client/fmp"
    require "../../app/models/client/twitter_wrapper"

    tomorrow = Time.at(1.day.since).strftime("%Y-%m-%d")
    dividends = Client::Fmp.get_dividend_calendar(from: tomorrow, to: tomorrow)

    symbols_text = dividends.map { |dividend| "$#{dividend[:symbol]}" }.sort.join(" ")

    tweet_text = <<~TWEET
      今日までの購入で配当金が受け取れる米国株は「#{dividends.count}件」です (配当落ち前日)
      #{symbols_text}
    TWEET
    Client::TwitterWrapper.tweet(tweet_text)
  end
end
