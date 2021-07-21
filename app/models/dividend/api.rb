# frozen_string_literal: true

class Dividend
  module Api
    RECENT_REFERENCE_START_DATE = Time.at(2.days.ago)

    def self.recent(from: RECENT_REFERENCE_START_DATE, to: nil)
      row_dividends = Client::Fmp.get_dividend_calendar(
        from: from,
        to: to,
      )
      to_instances(row_dividends)
    end

    def self.filter_by_ex_dividend_date(from_time = Time.now, _to_time = nil)
      return [] unless from_time.respond_to?(:strftime)

      from_date = from_time.strftime("%Y-%m-%d")
      to_date ||= from_date

      row_dividends = Client::Fmp.get_dividend_calendar(from: from_date, to: to_date)
      to_instances(row_dividends)
    end

    def self.to_instances(row_dividends = [])
      row_dividends.map do |dividend|
        Dividend.new(
          ex_dividend_on: dividend[:date],
          records_on: dividend[:record_date],
          pays_on: dividend[:payment_date],
          declares_on: dividend[:declaration_date],
          symbol: dividend[:symbol],
          dividend: dividend[:dividend],
          adjusted_dividend: dividend[:adj_dividend],
        )
      end
    end
  end
end
