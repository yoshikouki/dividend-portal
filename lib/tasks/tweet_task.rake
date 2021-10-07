# frozen_string_literal: true

namespace :tweet do
  desc "権利落ち前日の米国株を配信する"
  task ex_dividend_previous_date: :environment do
    today = Workday.today
    if today.holiday?(:us)
      Tweet.holiday(:us)
    elsif today.workday?(:us)
      Tweet.ex_dividend_previous_date(today)
    end
  end

  desc "新着の配当金情報を配信する"
  task latest_dividend_with_update: :environment do
    Tweet.latest_dividend
  end

  desc "配当貴族の配当金に関する新着情報を配信する"
  task new_dividend_of_dividend_aristocrats: :environment do
    Tweet.new_dividend_of_dividend_aristocrats
  end

  desc "配当貴族の週足値下がりランキングを配信する"
  task ranking_of_weekly_price_drop_rate: :environment do
    Tweet.new.ranking_of_weekly_price_drop_rate if Date.current.sunday?
  end

  desc "配当貴族の日足変動率ランキングを配信する"
  task ranking_of_daily_price_changing_rate: :environment do
    return unless Workday.today.yesterday.workday?(:us)

    Refresh.daily
    Tweet.new.ranking_of_daily_price_changing_rate
  end
end
