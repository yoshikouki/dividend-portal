# frozen_string_literal: true

class Dividend
  module Calculation
    class << self
      def dividend_growth_rate(dividends_in_chronological_order)
        last_dividend = 0
        dividends_in_chronological_order.map do |dividend|
          dividend_growth_rate = if last_dividend.zero?
            0
          else
            (dividend[:adjusted_dividend].to_d / last_dividend.to_d).to_f
          end
          last_dividend = dividend[:adjusted_dividend]
          dividend.merge(dividend_growth_rate: dividend_growth_rate)
        end
      end
    end
  end
end
