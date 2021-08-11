# frozen_string_literal: true

namespace :tweet do
  desc "権利落ち前日の米国株を配信する"
  task ex_dividend_previous_date: :environment do
    Dividend::Recent.refresh_us
    today = Workday.today
    if today.holiday?(:us)
      Tweet.holiday(:us)
    elsif today.workday?(:us)
      Tweet.ex_dividend_previous_date(today)
    end
  end

  desc "新着の配当金情報を配信する"
  task latest_dividend_with_update: :environment do
    Dividend::Recent.refresh_us
    Tweet.latest_dividend
  end
end
