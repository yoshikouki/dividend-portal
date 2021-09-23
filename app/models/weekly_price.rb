# frozen_string_literal: true

class WeeklyPrice
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :daily_prices

  attribute :symbol, :string
  attribute :date, :date
  attribute :open, :float
  attribute :close, :float
  attribute :adjusted_close, :float
  attribute :high, :float
  attribute :low, :float
  attribute :volume, :integer
  attribute :change, :float
  attribute :change_percent, :float

  attr_accessor :daily_prices

  def self.find_by_symbol_and_date(symbol, date = Date.current)
    daily_prices = Price.where(symbol: symbol).on_calendar_week(date).order(:date)
    weekly_price = new

    weekly_price.daily_prices = daily_prices
    weekly_price.symbol = symbol
    weekly_price.date = weekly_price.daily_prices.first.date
    weekly_price.open = weekly_price.daily_prices.first.open
    weekly_price.close = weekly_price.daily_prices.last.close
    weekly_price.adjusted_close = weekly_price.daily_prices.last.adjusted_close
    weekly_price.high = weekly_price.daily_prices.pluck(:high).max
    weekly_price.low = weekly_price.daily_prices.pluck(:low).min
    weekly_price.volume = weekly_price.daily_prices.pluck(:volume).sum
    weekly_price.change = (weekly_price.close.to_d - weekly_price.open.to_d).to_f
    weekly_price.change_percent = (weekly_price.close.to_d / weekly_price.open.to_d * 100 - 100).to_f
    weekly_price
  end
end
