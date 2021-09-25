# frozen_string_literal: true

class Price
  module Calculator
    def dividend_yield(reference_date)
      return @dividend_yield if @dividend_yield

      ttm_dividend = Dividend.where(symbol: symbol, ex_dividend_date: reference_date.last_year..reference_date).sum(:dividend)
      @dividend_yield = (ttm_dividend.to_d / close.to_d * 100).to_f
    end
  end
end
