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
      @dividends_attributes ||= dividends.map(&:to_dividend_attributes)
    end

    def unstored_dividend_attributes
      return [] if to_dividends_attributes.empty?

      dividends = to_dividends_attributes
      stored_dividends = ::Dividend.where(ex_dividend_date: from..to, symbol: symbols)
                                   .pluck(:ex_dividend_date, :symbol)
      dividends.flatten.filter_map do |attributes|
        next if stored_dividends.delete([attributes[:ex_dividend_date].to_date, attributes[:symbol]])

        attributes
      end
    end

    def self.historical(*symbols, from: nil, to: nil)
      dividend_calendar = []
      symbols.flatten.each_slice(5) do |up_to_5_symbols|
        historical_dividends = Fmp.historical_dividends(up_to_5_symbols, from: from, to: to)
        dividend_calendar += flatten_from_historical_hash(historical_dividends)
      end
      Fmp::DividendCalendar.new(dividend_calendar: dividend_calendar, symbols: symbols, from: from, to: to)
    end
  end
end
