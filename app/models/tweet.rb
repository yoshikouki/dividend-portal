# frozen_string_literal: true

class Tweet
  attr_accessor :client

  def self.holiday(_country = :us, workday = Workday.today)
    holiday = workday.holiday(:us).first[:name]
    content = "今日は「#{holiday}」の祝日なので、NY市場はお休みかも知れませんね"
    Client.tweet(content)
  end

  def self.ex_dividend_previous_date(date = Workday.today)
    # date が権利付き最終日の銘柄を調べるため、翌日が権利落ち日の銘柄を探す
    next_workday = date.next_workday
    dividends = Dividend.where(ex_dividend_date: next_workday)

    content = AssembledContent::Dividend.new(dividends: dividends, reference_date: date)
    tweet = Client.tweet(content.ex_dividend_previous_date)
    tweet = Client.tweet(content.remained_symbols, reply_to: tweet) while content.remained?
  end

  def self.latest_dividend
    dividends = Dividend.not_notified

    content = AssembledContent::Dividend.new(dividends: dividends)
    tweet = Client.tweet(content.latest_dividend)
    tweet = Client.tweet(content.remained_symbols, reply_to: tweet) while content.remained?

    dividends.update_all(notified: true)
  end

  def self.new_dividend_of_dividend_aristocrats
    ActiveRecord::Base.transaction do
      report_queue = ReportQueueOfDividendAristocratsDividend.dequeue
      return unless report_queue

      content = Tweet::Content::DividendReport.new
      text, image = content.new_dividend_of_dividend_aristocrats(report_queue.dividend.company)
      Client.tweet_with_image(text, image)
    end
  end

  def initialize(env = :production)
    @client = Client.new(env)
  end

  def ranking_of_weekly_price_drop_rate
    content = Tweet::Content::DividendAristocrats.new
    text, image = content.ranking_of_weekly_price_drop_rate
    client.tweet_with_image(text, image)
  end

  def ranking_of_daily_price_changing_rate
    content = Tweet::Content::DividendAristocrats.new
    text, image = content.ranking_of_daily_price_changing_rate
    client.tweet_with_image(text, image)
  end
end
