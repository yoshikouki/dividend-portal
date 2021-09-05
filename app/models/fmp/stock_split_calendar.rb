# frozen_string_literal: true

module Fmp
  class StockSplitCalendar
    extend Fmp::Converter

    attr_accessor :stock_split_calendar

    def initialize(stock_split_calendar = [])
      @stock_split_calendar = stock_split_calendar.map { |ss| Fmp::StockSplit.new(ss) }
    end

    def to_stock_splits_attributes
      @stock_split_calendar.map(&:to_stock_split_attributes)
    end

    def self.historical_for_bulk_symbols(*symbols, from: nil, to: nil)
      stock_split = []
      symbols.flatten.each_slice(5) do |up_to_5_symbols|
        historical_dividends = Fmp.historical_stock_splits(up_to_5_symbols, from: from, to: to)
        stock_split += flatten_from_historical_hash(historical_dividends)
      end
      new(stock_split)
    end
  end
end

