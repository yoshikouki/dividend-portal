# frozen_string_literal: true

namespace :tweet do
  desc "権利落ち前日の米国株を配信する"
  task ex_dividend_previous_date: :environment do
    Tweet.ex_dividend_previous_date
  end
end
