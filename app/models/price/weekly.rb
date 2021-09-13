# frozen_string_literal: true

class Price
  class Weekly
    attr_reader :daily_prices, :prices

    def self.dividend_aristocrats_in_order_of_change_percent(from: Date.current.beginning_of_week)
      symbols = Company.dividend_aristocrats.pluck(:symbol)
      prices = Price.retrieve_by_api(symbols: symbols, from: from)
      weekly_prices = calculate_from_daily_prices(prices)
      weekly_prices.ascending_order_of_change_percent
    end

    def self.calculate_from_daily_prices(daily_prices)
      new(daily_prices: daily_prices)
    end

    def initialize(daily_prices: nil)
      @daily_prices = daily_prices
    end

    def ascending_order_of_change_percent
      self
    end

    def all
      @prices
    end
  end
end
