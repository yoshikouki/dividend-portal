# frozen_string_literal: true

module Refresh
  module Dividend
    class << self
      def remove_outdated(outdated: BEGINNING_OF_DIVIDEND_STORAGE_PERIOD.yesterday)
        ::Dividend.where(ex_dividend_date: ..outdated).destroy_all
      end

      def update_us(from: BEGINNING_OF_DIVIDEND_STORAGE_PERIOD)
        ::Dividend.insert_all_with_api!(from: from)
      end

      def enqueue_dividend_report(dividend_ids)
        ReportQueueOfDividendAristocratsDividend.enqueue(dividend_ids: dividend_ids)
      end
    end
  end
end
