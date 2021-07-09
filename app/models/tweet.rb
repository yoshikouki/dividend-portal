# frozen_string_literal: true

module Tweet
  def self.tweet(text)
    client = Client.new
    client.update(text)
  end

  def self.ex_dividend_previous_date
    # TODO NY市場の翌営業日を取得する
    tomorrow = Time.at(1.day.since)
    dividends = Dividend.filter_by_ex_dividend_date(tomorrow)

    tweet_text = render_ex_dividend_previous_date(dividends)
    tweet(tweet_text)
  end

  def self.render_ex_dividend_previous_date(dividends = [])
    symbols_text = dividends.map { |dividend| "$#{dividend[:symbol]}" }.sort.join(" ")

    <<~TWEET
      今日までの購入で配当金が受け取れる米国株は「#{count}件」です (配当落ち前日)
      #{symbols_text}
    TWEET
  end
end
