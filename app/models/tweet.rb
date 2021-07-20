# frozen_string_literal: true

module Tweet
  def self.tweet(text)
    client = Client.new
    client.update(text)
  end

  def self.holiday(_country = :us, workday = Workday.today)
    holiday = workday.holiday(:us).first[:name]
    content = "今日は「#{holiday}」の祝日なので、NY市場はお休みかも知れませんね"
    tweet(content)
  end

  def self.ex_dividend_previous_date(date = Workday.today)
    # date までに購入すると配当金の権利落ちする銘柄を調べるため、翌日が権利落ち日の銘柄を探す
    next_workday = date.next_workday
    dividends = Dividend.filter_by_ex_dividend_date(next_workday)

    tweet_content = render_ex_dividend_previous_date(dividends)
    tweet(tweet_content)
  end

  def self.render_ex_dividend_previous_date(dividends = [])
    content_for_calculation = template_for_ex_dividend_previous_date(dividends.count)
    tweet_symbols = []

    dividends.each do |dividend|
      content_for_calculation += "$#{dividend[:symbol]} "
      break if Twitter::TwitterText::Validation.parse_tweet(content_for_calculation)[:weighted_length] > 240

      tweet_symbols << dividend[:symbol]
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

  def self.latest_dividend
    dividends = Dividend.not_notified
    tweet_content = Content.latest_dividend(dividends)
    tweet(tweet_content)
    dividends.update_all(notified: true)
  end
end
