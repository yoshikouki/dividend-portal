# frozen_string_literal: true

module Fmp
  class DividendCalendar
    include ActiveModel::Model
    extend Fmp::Converter

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
      dividend_calendar = new
      symbols.flatten.each_slice(5) do |up_to_5_symbols|
        historical_dividends = Fmp.historical_dividends(up_to_5_symbols, from: from, to: to)
        dividend_calendar.dividend_calendar += flatten_from_historical_hash(historical_dividends)
      end
      dividend_calendar
    end
  end
end
