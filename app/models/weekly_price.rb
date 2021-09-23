# frozen_string_literal: true

class WeeklyPrice
  include ActiveModel::Model
  include ActiveModel::Attributes

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
    new(symbol: symbol).calculate_from_daily_prices(daily_prices)
  end

  def self.dividend_aristocrats(date = Date.current)
    Company::DividendAristocrat.symbols.map do |symbol|
      find_by_symbol_and_date(symbol, date)
    end
  end

  def self.dividend_aristocrats_sort_by_change_percent(date = Date.current)
    dividend_aristocrats(date).sort_by(&:change_percent)
  end

  def calculate_from_daily_prices(daily_prices)
    self.daily_prices = daily_prices
    daily_prices = daily_prices.to_a
    self.date = daily_prices.first.date
    self.open = daily_prices.first.open
    self.close = daily_prices.last.close
    self.adjusted_close = daily_prices.last.adjusted_close
    self.high = daily_prices.pluck(:high).max
    self.low = daily_prices.pluck(:low).min
    self.volume = daily_prices.pluck(:volume).sum
    self.change = (close.to_d - open.to_d).to_f
    self.change_percent = (close.to_d / open.to_d * 100 - 100).to_f
    self
  end
end
