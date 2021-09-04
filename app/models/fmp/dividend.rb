# frozen_string_literal: true

module Fmp
  class Dividend
    # ActiveModel::Attributes だと数百〜数千件のインスタンスを扱うのに重いため純粋に定義する
    attr_accessor :date, :symbol, :dividend, :adj_dividend, :declaration_date, :label, :record_date, :payment_date

    def initialize(arg)
      parse_and_assign(arg)
    end

    private

    def parse_and_assign(arg)
      arg = remove_empty_string(arg)
      @date = Date.parse(arg[:date])
      @symbol = arg[:symbol]
      @dividend = arg[:dividend]
      @adj_dividend = arg[:adj_dividend]
      @label = arg[:label]
      @declaration_date = Date.parse(arg[:declaration_date]) if arg[:declaration_date]
      @record_date = Date.parse(arg[:record_date]) if arg[:record_date]
      @payment_date = Date.parse(arg[:payment_date]) if arg[:payment_date]
    end

    def remove_empty_string(arg)
      arg.transform_values { |v| v == "" ? nil : v }
    end
  end
end
