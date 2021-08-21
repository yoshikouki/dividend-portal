# frozen_string_literal: true

module Client
  module Fmp
    API_HOST = "financialmodelingprep.com"
    API_KEY = ENV["API_KEY_FMP"]

    START_DATE_OF_RECENT_DIVIDEND = Time.now.ago(3.days)

    # https://financialmodelingprep.com/developer/docs#Company-Profile
    # https://financialmodelingprep.com/developer/docs/companies-key-stats-free-api
    def self.profile(*symbols)
      param = symbols_to_param(symbols)
      res = Client.get url("/api/v3/profile/#{param}")
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # https://financialmodelingprep.com/developer/docs#Symbols-List
    # https://financialmodelingprep.com/developer/docs/stock-market-quote-free-api
    def self.get_symbols_list
      res = Client.get url("/api/v3/stock/list")
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # https://financialmodelingprep.com/developer/docs#ETF-List
    # https://financialmodelingprep.com/developer/docs/etf-list
    def self.get_etf_list
      res = Client.get url("/api/v3/etf/list")
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # https://financialmodelingprep.com/developer/docs#Tradable-Symbols-List
    # https://financialmodelingprep.com/developer/docs/tradable-list
    def self.get_tradable_symbols_list
      res = Client.get url("/api/v3/available-traded/list")
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # to の最長期間は from から3ヶ月
    # https://financialmodelingprep.com/developer/docs#Dividend-Calendar
    # https://financialmodelingprep.com/developer/docs/dividend-calendar
    def self.get_dividend_calendar(from: nil, to: nil)
      path = "/api/v3/stock_dividend_calendar"
      query = from_and_to_query(from, to)

      res = Client.get url(path, query)
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    def self.sp500
      res = Client.get url("api/v3/sp500_constituent")
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    def self.historical_dividends(*symbols, from: nil, to: nil)
      path = "/api/v3/historical-price-full/stock_dividend/#{symbols_to_param(symbols)}"
      query = from_and_to_query(from, to)

      res = Client.get url(path, query)
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    # https://financialmodelingprep.com/developer/docs/company-outlook
    def self.company_outlook(symbol)
      path = "api/v4/company-outlook"
      query = {
        symbol: symbol,
      }
      res = Client.get url(path, query)
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    def self.symbols_to_param(symbols)
      param = symbols_to_s(symbols)
      # symbol に / を含むものが紛れており、エラーになるので変換する
      convert_symbol_to_profile_query(param)
    end

    def self.symbols_to_s(symbols)
      case symbols
      when Array
        symbols.join(",")
      when String
        symbols
      end
    end

    def self.convert_symbol_to_profile_query(symbol)
      symbol.gsub(%r{[/_]}, "-")
    end

    def self.from_and_to_query(from, to)
      query = {}
      query[:from] = from if from
      query[:to] = to if to
      Client.value_to_time query
    end

    def self.url(path, query_hash = {})
      path = "/#{path}" if path[0] != "/"
      throw("Invalid pattern") if path[1] == "/"

      query = ""
      unless query_hash.empty?
        query_hash.each do |key, value|
          query += "&#{key}=#{value}" if value
        end
      end

      "https://#{API_HOST}#{path}?apikey=#{API_KEY}#{query}"
    end
  end
end
