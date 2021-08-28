# frozen_string_literal: true

module Tweet
  # reply_to: Twitter::Tweet
  def self.tweet(text, reply_to: nil, dev: false)
    client = Client.new(dev: dev)
    option = reply_to ? { in_reply_to_status: reply_to } : {}
    client.update(text, option)
  end

  def self.holiday(_country = :us, workday = Workday.today)
    holiday = workday.holiday(:us).first[:name]
    content = "今日は「#{holiday}」の祝日なので、NY市場はお休みかも知れませんね"
    tweet(content)
  end

  def self.ex_dividend_previous_date(date = Workday.today)
    # date が権利付き最終日の銘柄を調べるため、翌日が権利落ち日の銘柄を探す
    next_workday = date.next_workday
    dividends = Dividend.where(ex_dividend_on: next_workday)

    content = AssembledContent::Dividend.new(dividends: dividends, reference_date: date)
    tweet = tweet(content.ex_dividend_previous_date)
    tweet = tweet(content.remained_symbols, reply_to: tweet) while content.remained?
  end

  def self.latest_dividend
    dividends = Dividend.not_notified

    content = AssembledContent::Dividend.new(dividends: dividends)
    tweet = tweet(content.latest_dividend)
    tweet = tweet(content.remained_symbols, reply_to: tweet) while content.remained?

    dividends.update_all(notified: true)
  end

  def self.new_dividend_of_dividend_aristocrats
    report_queue = ReportQueueOfDividendAristocratsDividend.dequeue
    return unless report_queue

    content = Tweet::Content::DividendReport.new
    tweet(content.new_dividend_of_dividend_aristocrats(report_queue))
  end
end
