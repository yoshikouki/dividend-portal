# frozen_string_literal: true

module Fmp
  class Dividend
    # ActiveModel::Attributes だと数百〜数千件のインスタンスを扱うのに重いため純粋に定義する
    attr_accessor :date, :symbol, :dividend, :adj_dividend, :declaration_date, :label, :record_date, :payment_date

    CONVERSION_TABLE_OF_DIVIDEND_CALENDAR = {
      ex_dividend_date: :date,
      records_on: :record_date,
      pays_on: :payment_date,
      declares_on: :declaration_date,
      symbol: :symbol,
      dividend: :dividend,
      adjusted_dividend: :adj_dividend,
    }.freeze

    def initialize(arg)
      parse_and_assign(arg)
    end

    def to_dividend_attributes
      CONVERSION_TABLE_OF_DIVIDEND_CALENDAR.filter_map { |after, before| [after, send(before)] }.to_h
    end

    private

    def parse_and_assign(arg)
      arg = remove_empty_string(arg)
      @symbol = arg[:symbol]
      @dividend = arg[:dividend]
      @adj_dividend = arg[:adj_dividend]
      @label = Date.parse(arg[:label]).strftime("%Y-%m-%d") if arg[:label]
      %i[date declaration_date record_date payment_date].each { |sym| instance_variable_set("@#{sym}", arg[sym]) if arg[sym] }
    end

    def remove_empty_string(arg)
      arg.transform_values { |v| v == "" ? nil : v }
    end
  end
end
