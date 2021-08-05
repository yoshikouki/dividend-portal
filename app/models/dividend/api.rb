# frozen_string_literal: true

class Dividend
  module Api
    RECENT_REFERENCE_START_DATE = Time.at(2.days.ago)

    CONVERSION_TABLE_OF_DIVIDEND_CALENDAR = {
      date: :ex_dividend_on,
      record_date: :records_on,
      payment_date: :pays_on,
      declaration_date: :declares_on,
      symbol: :symbol,
      dividend: :dividend,
      adj_dividend: :adjusted_dividend,
    }

    def self.recent(from: RECENT_REFERENCE_START_DATE, to: nil)
      row_dividends = Client::Fmp.get_dividend_calendar(
        from: from,
        to: to,
      )
      convert_response_of_dividend_calendar(row_dividends)
    end

    def self.filter_by_ex_dividend_date(from_time = Time.now, _to_time = nil)
      return [] unless from_time.respond_to?(:strftime)

      from_date = from_time.strftime("%Y-%m-%d")
      to_date ||= from_date

      row_dividends = Client::Fmp.get_dividend_calendar(from: from_date, to: to_date)
      to_instances(row_dividends)
    end

    def self.convert_response_of_dividend_calendar(row_dividends = [])
      CONVERSION_TABLE_OF_DIVIDEND_CALENDAR.map { |k, v| [v, row_dividends[k]] }.to_h
    end

    def self.to_instances(row_dividends = [])
      convert_response_of_dividend_calendar(row_dividends).map { |attr| Dividend.new(attr) }
    end
  end
end
