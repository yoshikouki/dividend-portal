# frozen_string_literal: true

module Fmp
  class DividendCalendar
    include ActiveModel::Model
    include ActiveModel::Attributes
    extend Fmp::Converter

    attribute :dividend_calendar, :array_of_fmp_dividends, default: []
    attribute :symbols, :array_of_strings
    attribute :from, :date
    attribute :to, :date

    def dividends
      dividend_calendar
    end

    def to_dividends_attributes
      dividend_calendar.map(&:to_dividend_attributes)
    end

    def self.historical(*symbols, from: nil, to: nil)
      fdc = Fmp::DividendCalendar.new(symbols: symbols, from: from, to: to)
      symbols.flatten.each_slice(5) do |up_to_5_symbols|
        historical_dividends = Fmp.historical_dividends(up_to_5_symbols, from: from, to: to)
        fdc.dividend_calendar += flatten_from_historical_hash(historical_dividends)
      end
      fdc
    end
  end
end
