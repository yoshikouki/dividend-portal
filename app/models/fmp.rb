# frozen_string_literal: true

module Fmp
  START_DATE_OF_RECENT_DIVIDEND = Time.now.ago(3.days)

  class << self
    # https://financialmodelingprep.com/developer/docs#Company-Profile
    # https://financialmodelingprep.com/developer/docs/companies-key-stats-free-api
    def profile(*symbols)
      param = Converter.symbols_to_param(symbols)
      Client.get("/api/v3/profile/#{param}")
    end

    # https://financialmodelingprep.com/developer/docs#Symbols-List
    # https://financialmodelingprep.com/developer/docs/stock-market-quote-free-api
    def symbols_list
      Client.get("/api/v3/stock/list")
    end

    # https://financialmodelingprep.com/developer/docs#ETF-List
    # https://financialmodelingprep.com/developer/docs/etf-list
    def etf_list
      Client.get("/api/v3/etf/list")
    end

    # https://financialmodelingprep.com/developer/docs#Tradable-Symbols-List
    # https://financialmodelingprep.com/developer/docs/tradable-list
    def tradable_symbols_list
      Client.get("/api/v3/available-traded/list")
    end

    # to の最長期間は from から3ヶ月
    # https://financialmodelingprep.com/developer/docs#Dividend-Calendar
    # https://financialmodelingprep.com/developer/docs/dividend-calendar
    def dividend_calendar(from: nil, to: nil)
      path = "/api/v3/stock_dividend_calendar"
      query = Converter.from_and_to_query(from, to)
      Client.get(path, query)
    end

    def sp500
      Client.get("api/v3/sp500_constituent")
    end

    def historical_dividends(*symbols, from: nil, to: nil)
      path = "/api/v3/historical-price-full/stock_dividend/#{Converter.symbols_to_param(symbols)}"
      query = Converter.from_and_to_query(from, to)
      Client.get(path, query)
    end

    # 株式分割の情報を取得
    # https://financialmodelingprep.com/developer/docs/historical-stock-splits
    def historical_stock_splits(symbol)
      path = "/api/v3/historical-price-full/stock_split/#{Converter.symbols_to_param(symbol)}"
      Client.get(path)
    end

    # https://financialmodelingprep.com/developer/docs/company-outlook
    def company_outlook(symbol)
      path = "api/v4/company-outlook"
      query = { symbol: symbol }
      Client.get(path, query)
    end

    # @option period [Symbol] :quarter or :annual
    # https://financialmodelingprep.com/developer/docs#Company-Financial-Growth
    # https://financialmodelingprep.com/developer/docs/company-financial-statement-growth-api
    def financial_growth(symbol, period: :annual)
      path = "api/v3/financial-growth/#{symbol}"
      query = { period: period }
      Client.get(path, query)
    end
  end
end
