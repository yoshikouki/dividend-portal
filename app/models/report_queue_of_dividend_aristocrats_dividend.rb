# frozen_string_literal: true

class ReportQueueOfDividendAristocratsDividend < ReportQueue
  class << self
    def enqueue(dividend_ids: nil)
      dividend_aristocrats_dividends = Dividend.dividend_aristocrats.where(id: dividend_ids)
      queues = dividend_aristocrats_dividends.pluck(:id).map do |dividend_id|
        now = Time.current
        { dividend_id: dividend_id, type: self, created_at: now, updated_at: now }
      end
      return if queues.empty?

      insert_all(queues)
    end
  end
end
