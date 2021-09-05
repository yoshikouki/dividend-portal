# frozen_string_literal: true

module Fmp
  class DividendCalendar
    include ActiveModel::Model

    attr_accessor :dividend_calendar

    def initialize(dividend_calendar = [])
      @dividend_calendar = dividend_calendar.map { |d| Fmp::Dividend.new(d) }
    end

    def dividends
      @dividend_calendar
    end

    def to_dividends_attributes
      @dividend_calendar.map(&:to_dividend_attributes)
    end

    def self.historical(*symbols, from: nil, to: nil)
      warn "[WARNING] use up to 5 symbols" if symbols.count > 5
      historical_dividends = Fmp.historical_dividends(symbols, from: from, to: to)
      dividend_calendar = flatten_from_historical_dividends(historical_dividends)
      new(dividend_calendar)
    end

    def self.historical_for_bulk_symbols(*symbols, from: nil, to: nil)
      dividend_calendar = []
      symbols.flatten.each_slice(5) do |up_to_5_symbols|
        historical_dividends = Fmp.historical_dividends(up_to_5_symbols, from: from, to: to)
        dividend_calendar += flatten_from_historical_dividends(historical_dividends)
      end
      new(dividend_calendar)
    end

    class << self
      private

      def flatten_from_historical_dividends(historical_dividends)
        flattened = []
        if historical_dividends.key?(:historical)
          dividends = historical_dividends[:historical].map { |dividend| dividend.merge(symbol: historical_dividends[:symbol]) }
          flattened = dividends
        elsif historical_dividends.key?(:historical_stock_list)
          historical_dividends[:historical_stock_list].each do |historical_dividends_by_symbol|
            flattened += flatten_from_historical_dividends(historical_dividends_by_symbol)
          end
        end
        flattened
      end
    end
  end
end
