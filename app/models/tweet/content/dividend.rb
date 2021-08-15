# frozen_string_literal: true

module Tweet
  class Content
    class Dividend < Tweet::Content
      def initialize(report_queue:)
        @report_queue = report_queue
        super
      end

      def new_dividend_of_dividend_aristocrats
        assigns = {}
        self.class.render(
          template: template_path(__method__),
          assigns: assigns,
        )
      end
    end
  end
end
