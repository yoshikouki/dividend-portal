# frozen_string_literal: true

module Tweet
  def self.tweet(text)
    client = Client.new
    client.update(text)
  end

  def self.ex_dividend_previous_date
    tomorrow = Time.at(1.day.since)
    dividends = Dividend.filter_by_ex_dividend_date(tomorrow)

    # ツイート文面を作成
    symbols_text = dividends.map { |dividend| "$#{dividend[:symbol]}" }.sort.join(" ")
      symbols_text.length

    # ツイート
    tweet_text = render_ex_dividend_previous_date(dividends.count, symbols_text)
    tweet(tweet_text)
  end

  def self.render_ex_dividend_previous_date(count = nil, symbols_text = nil)
    <<~TWEET
      今日までの購入で配当金が受け取れる米国株は「#{count}件」です (配当落ち前日)
      #{symbols_text}
    TWEET
  end
end
