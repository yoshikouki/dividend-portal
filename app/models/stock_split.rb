# frozen_string_literal: true

class StockSplit < ApplicationRecord
  DEFAULT_INSERT_ALL = {
    date: nil,
    symbol: nil,
    numerator: nil,
    denominator: nil,
    created_at: Time.current,
    updated_at: Time.current,
  }.freeze

  def self.insert_all_from_stock_split_calendar!(stock_split_calendar)
    stock_split_calendar = merge_timestamp(stock_split_calendar)
    insert_all!(stock_split_calendar)
  end

  class << self
    private

    def merge_timestamp(stock_split_calendar)
      # insert_all は全て同じキーを持ったハッシュ配列である必要があるため、冗長だがテンプレートにマージする
      stock_split_calendar.map { |stock_split| DEFAULT_INSERT_ALL.merge(stock_split) }
    end
  end
end
