# frozen_string_literal: true

class Tweet
  class Content
    class DividendAristocrats < Tweet::Content
      def ranking_of_weekly_price_drop_rate(reference_date: Date.current)
        ranking_of_weekly_price_drop = WeeklyPrice.dividend_aristocrats_sorted_by_change_percent(reference_date).slice(0, 5)
        assigns = {
          reference_date: reference_date,
          ranking: ranking_of_weekly_price_drop,
        }
        render(file_name: __method__, assigns: assigns)
      end
    end
  end
end
