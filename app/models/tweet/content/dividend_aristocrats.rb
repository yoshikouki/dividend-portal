# frozen_string_literal: true

class Tweet
  class Content
    class DividendAristocrats < Tweet::Content
      def ranking_of_weekly_price_drop_rate(reference_date: Date.current)
        ranking_of_weekly_price_drop = WeeklyPrice.dividend_aristocrats_sorted_by_change_percent(reference_date).slice(0, 5)
        prices_for_one_year = Price.where(symbol: ranking_of_weekly_price_drop[0].symbol, date: reference_date.last_year..reference_date)
        assigns = {
          ranking: ranking_of_weekly_price_drop,
        }
        text = render(file_name: __method__, assigns: assigns)
        image = Chart.new.line_chart_of_price(prices_for_one_year)
        [text, image]
      end
    end
  end
end
