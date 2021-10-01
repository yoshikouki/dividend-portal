# frozen_string_literal: true

class Tweet
  class Content
    class DividendAristocrats < Tweet::Content
      def ranking_of_weekly_price_drop_rate(reference_date: Date.current)
        ranking_of_weekly_price_drop = WeeklyPrice.dividend_aristocrats_sorted_by_change_percent(reference_date).slice(0, 5)
        raise "株価が取得できなかったので処理を中断します" if ranking_of_weekly_price_drop.length.zero?

        prices_for_one_year = Price.where_from_api(symbol: ranking_of_weekly_price_drop[0].symbol, date: reference_date.last_year..reference_date)
        assigns = {
          reference_date: reference_date,
          ranking: ranking_of_weekly_price_drop,
        }
        text = render(file_name: __method__, assigns: assigns)
        image = Chart.new.line_chart_of_price(prices_for_one_year)
        [text, image]
      end

      def ranking_of_daily_price_changing_rate(reference_date: Date.current)
        daily_prices_sorted_by_change_rate = Price.where(date: reference_date.yesterday, symbol: Company::DividendAristocrat.symbols).order(:change_percent)
        prices_of_worst_symbol_for_one_year = Price.where_from_api(symbol: daily_prices_sorted_by_change_rate.first.symbol,
                                                                   date: reference_date.last_year..reference_date)
        text = render(file_name: __method__, assigns: {
                        reference_date: reference_date,
                        worst_three_of_change_percent: daily_prices_sorted_by_change_rate[..2],
                        best_three_of_change_percent: daily_prices_sorted_by_change_rate[-3..],
                      })
        image = Chart.new.line_chart_of_price(prices_of_worst_symbol_for_one_year)
        [text, image]
      end
    end
  end
end
