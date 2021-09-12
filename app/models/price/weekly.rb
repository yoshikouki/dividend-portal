# frozen_string_literal: true

class Price
  class Weekly
    attr_accessor :price_history

    def initialize(daily: nil)
      @price_history = price_history
    end

    def self.dividend_aristocrats_in_order_of_change_percent(from: Date.current.beginning_of_week)
      [
        {date: "2021-09-01",
         open: 56.38,
         high: 56.8,
         low: 56.28,
         close: 56.69,
         volume: 9404637.0,
         change: 0.31,
         change_percent: 0.55,
         symbol: "KO"},
      ]
    end
  end
end

