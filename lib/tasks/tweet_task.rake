# frozen_string_literal: true

namespace :tweet do
  desc "権利落ち前日の米国株を配信する"
  task ex_dividend_previous_date: :environment do
    Refresh.daily
    today = Workday.today
    if today.holiday?(:us)
      Tweet.holiday(:us)
    elsif today.workday?(:us)
      Tweet.ex_dividend_previous_date(today)
    end
  end

  desc "新着の配当金情報を配信する"
  task latest_dividend_with_update: :environment do
    Refresh.daily
    Tweet.latest_dividend
  end

  desc "配当貴族の配当金に関する新着情報を配信する"
  task new_dividend_of_dividend_aristocrats: :environment do
    Refresh.daily
    Tweet.new_dividend_of_dividend_aristocrats
  end
end
