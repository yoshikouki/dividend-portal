# frozen_string_literal: true

module Fmp
  class StockSplit

    attr_accessor :date, :symbol, :label, :numerator, :denominator

    CONVERSION_TABLE_OF_STOCK_SPLIT = {
      date: :date,
      symbol: :symbol,
      numerator: :numerator,
      denominator: :denominator,
    }.freeze

    def initialize(arg)
      parse_and_assign(arg)
    end

    def to_stock_split_attributes
      CONVERSION_TABLE_OF_STOCK_SPLIT.filter_map { |after, before| [after, send(before)] }.to_h
    end

    private

    def parse_and_assign(arg)
      @date = Date.parse(arg[:date]) if arg[:date]
      @symbol = arg[:symbol]
      @numerator = arg[:numerator]
      @denominator = arg[:denominator]
      @label = Date.parse(arg[:label]).strftime("%Y-%m-%d") if arg[:label]
    end
  end
end
