# frozen_string_literal: true

FactoryBot.define do
  factory :report_queue_of_dividend_aristocrats_dividend do
    type { ReportQueueOfDividendAristocratsDividend }
    dividend { nil }
  end
end
