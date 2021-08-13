# frozen_string_literal: true

class ReportQueueOfDividendAristocratsDividend < ReportQueue
  class << self
    def enqueue(dividend_ids: nil)
      queues = dividend_ids.map do |dividend_id|
        now = Time.current
        { dividend_id: dividend_id, type: self, created_at: now, updated_at: now }
      end
      insert_all(queues)
    end
  end
end
