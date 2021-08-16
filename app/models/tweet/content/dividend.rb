# frozen_string_literal: true

module Tweet
  class Content
    class Dividend < Tweet::Content
      def new_dividend_of_dividend_aristocrats(report_queue)
        assigns = {}
        self.class.render(
          template: template_path(__method__),
          assigns: assigns,
        )
      end
    end
  end
end
