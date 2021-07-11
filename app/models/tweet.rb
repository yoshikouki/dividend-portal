# frozen_string_literal: true

module Tweet
  def self.tweet(text)
    client = Client.new
    client.update(text)
  end

  def self.ex_dividend_previous_date
    # TODO: NY市場の翌営業日を取得する
    tomorrow = Time.at(1.day.since)
    dividends = Dividend.filter_by_ex_dividend_date(tomorrow)

    tweet_content = render_ex_dividend_previous_date(dividends)
    tweet(tweet_content)
  end

  def self.render_ex_dividend_previous_date(dividends = [])
    content_for_calculation = template_for_ex_dividend_previous_date(dividends.count)
    tweet_symbols = []

    dividends.each do |dividend|
      content_for_calculation += "$#{dividend[:symbol]} "
      if Twitter::TwitterText::Validation.parse_tweet(content_for_calculation)[:weighted_length] < 240
        tweet_symbols << dividend[:symbol]
      else
        break
      end
    end
    remaining_count = dividends.count - tweet_symbols.count
    template_for_ex_dividend_previous_date(dividends.count, tweet_symbols, remaining_count)
  end

  def self.template_for_ex_dividend_previous_date(dividends_count = 0, tweet_symbols = [], remaining_count = 0)
    front_part = "今日までの購入で配当金が受け取れる米国株は「#{dividends_count}件」です (配当落ち前日)"
    return front_part if dividends_count.zero?

    symbols_part = tweet_symbols.map { |s| "$#{s}" }.join(" ")
    symbols_part += "...他#{remaining_count}件" if remaining_count.positive?

    <<~TWEET
      #{front_part}
      #{symbols_part}
    TWEET
  end
end
