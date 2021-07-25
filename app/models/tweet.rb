# frozen_string_literal: true

module Tweet
  # reply_to: Twitter::Tweet
  def self.tweet(text, reply_to: nil)
    client = Client.new
    option = reply_to ? { in_reply_to_status: reply_to } : {}
    client.update(text, option)
  end

  def self.holiday(_country = :us, workday = Workday.today)
    holiday = workday.holiday(:us).first[:name]
    content = "今日は「#{holiday}」の祝日なので、NY市場はお休みかも知れませんね"
    tweet(content)
  end

  def self.ex_dividend_previous_date(date = Workday.today)
    # 権利付き最終日が date の銘柄を調べるため、翌日が権利落ち日の銘柄を探す
    next_workday = date.next_workday
    dividends = Dividend::Api.filter_by_ex_dividend_date(next_workday)

    content = Content::Dividend.new(dividends: dividends, reference_date: date)
    tweet = tweet(content.ex_dividend_previous_date)
    tweet = tweet(content.remained_symbols, reply_to: tweet) while content.remained?
  end

  def self.latest_dividend
    dividends = Dividend.not_notified

    content = Content::Dividend.new(dividends: dividends)
    tweet = tweet(content.latest_dividend)
    tweet = tweet(content.remained_symbols, reply_to: tweet) while content.remained?

    dividends.update_all(notified: true)
  end
end
