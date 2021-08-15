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
    }.freeze

    def self.recent(from: RECENT_REFERENCE_START_DATE, to: nil)
      row_dividends = Client::Fmp.get_dividend_calendar(
        from: from,
        to: to,
      )
      convert_response_of_dividend_calendar(row_dividends)
    end

    def self.convert_response_of_dividend_calendar(row_dividends = [])
      row_dividends.map do |dividend|
        # APIレスポンスがnullの祭に変換処理で空文字になることがあってバグになったので、明示的にnilに変換する
        dividend.transform_values { |v| v == "" ? nil : v }
        CONVERSION_TABLE_OF_DIVIDEND_CALENDAR.map { |k, v| [v, dividend[k]] }.to_h
      end
    end

    def self.all(symbols, from: nil, to: nil)
      row_dividends = Client::Fmp.historical_dividends(
        symbols,
        from: from,
        to: to,
      )
      row_dividends[:historical] = convert_response_of_dividend_calendar(row_dividends[:historical])
    end
  end
end
