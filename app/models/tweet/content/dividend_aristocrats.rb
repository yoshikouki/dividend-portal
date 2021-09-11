# frozen_string_literal: true

class Tweet
  class Content
    class DividendAristocrats < Tweet::Content
      def ranking_of_weekly_price_drop_rate(reference_date: Date.current)
        text = render(file_name: __method__, assigns: assigns)
        image = Chart.new.ranking_of_weekly_price_drop_rate
        [text, image]
      end
    end
  end
end
