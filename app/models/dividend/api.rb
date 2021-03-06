# frozen_string_literal: true

class Dividend
  module Api
    RECENT_REFERENCE_START_DATE = Time.at(2.days.ago)

    def self.recent(from: RECENT_REFERENCE_START_DATE, to: nil)
      row_dividends = Fmp.dividend_calendar(
        from: from,
        to: to,
      )
      Converter.convert_response_of_dividend_calendar(row_dividends)
    end

    def self.all(symbols, from: nil, to: nil)
      historical_dividends = Fmp.historical_dividends(
        symbols,
        from: from,
        to: to,
      )
      if historical_dividends[:historical_stock_list]
        Converter.historical_stock_list(historical_dividends)
      else
        Converter.convert_response_of_historical_calendar(historical_dividends)
      end
    end

    def self.outlook(symbol)
      response = Fmp.company_outlook(symbol)
      Converter.convert_response_of_company_outlook(response)
    end

    def self.all_adjusted(symbol, from: nil, to: nil)
      historical_dividends = all(symbol, from: from, to: to)
      historical_stock_splits = Fmp.historical_stock_splits(symbol)
      Converter.recalculate_adjusted_dividend(historical_dividends, historical_stock_splits[:historical])
    end
  end
end
