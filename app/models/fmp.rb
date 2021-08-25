# frozen_string_literal: true

module Fmp
  START_DATE_OF_RECENT_DIVIDEND = Time.now.ago(3.days)

  class << self
    # https://financialmodelingprep.com/developer/docs#Company-Profile
    # https://financialmodelingprep.com/developer/docs/companies-key-stats-free-api
    def profile(*symbols)
      param = Converter.symbols_to_param(symbols)
      res = Client.get("/api/v3/profile/#{param}")
      Converter.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # https://financialmodelingprep.com/developer/docs#Symbols-List
    # https://financialmodelingprep.com/developer/docs/stock-market-quote-free-api
    def symbols_list
      res = Client.get("/api/v3/stock/list")
      Converter.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # https://financialmodelingprep.com/developer/docs#ETF-List
    # https://financialmodelingprep.com/developer/docs/etf-list
    def etf_list
      res = Client.get("/api/v3/etf/list")
      Converter.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # https://financialmodelingprep.com/developer/docs#Tradable-Symbols-List
    # https://financialmodelingprep.com/developer/docs/tradable-list
    def tradable_symbols_list
      res = Client.get("/api/v3/available-traded/list")
      Converter.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # to の最長期間は from から3ヶ月
    # https://financialmodelingprep.com/developer/docs#Dividend-Calendar
    # https://financialmodelingprep.com/developer/docs/dividend-calendar
    def dividend_calendar(from: nil, to: nil)
      path = "/api/v3/stock_dividend_calendar"
      query = Converter.from_and_to_query(from, to)
      res = Client.get(path, query)
      Converter.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    def sp500
      res = Client.get("api/v3/sp500_constituent")
      Converter.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    def historical_dividends(*symbols, from: nil, to: nil)
      path = "/api/v3/historical-price-full/stock_dividend/#{Converter.symbols_to_param(symbols)}"
      query = Converter.from_and_to_query(from, to)
      res = Client.get(path, query)
      Converter.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # https://financialmodelingprep.com/developer/docs/company-outlook
    def company_outlook(symbol)
      path = "api/v4/company-outlook"
      query = { symbol: symbol }
      res = Client.get(path, query)
      Converter.parse_response_body(body: res.body, content_type: res["content-type"])
    end
  end
end
