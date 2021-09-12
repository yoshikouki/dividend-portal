# frozen_string_literal: true

class Tweet
  class Content
    class DividendAristocrats < Tweet::Content
      def ranking_of_weekly_price_drop_rate(reference_date: Date.current)
        ranking_of_weekly_price_drop = Price::Weekly.dividend_aristocrats_in_order_of_change_percent(from: reference_date.beginning_of_week)
        prices_for_one_year = Price.retrieve_by_api(symbols: ranking_of_weekly_price_drop.first, from: Date.current.last_year)
        assigns = {
          ranking: ranking_of_weekly_price_drop[0..4],
        }
        text = render(file_name: __method__, assigns: assigns)
        image = Chart.new.line_chart_of_price(prices_for_one_year)
        [text, image]
      end
    end
  end
end
