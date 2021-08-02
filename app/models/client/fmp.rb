# frozen_string_literal: true

module Client
  module Fmp
    API_HOST = "financialmodelingprep.com"
    API_KEY = ENV["API_KEY_FMP"]

    START_DATE_OF_RECENT_DIVIDEND = Time.now.ago(3.days)

    DIVIDEND_CALENDAR_CONVERSION = {
      date: "ex-dividend date", # "権利落ち日"
      label: "label", # "権利落ち日(英語表記)"
      record_date: "record date", # "権利確定日"
      payment_date: "payment date", # "支払日"
      declaration_date: "declaration date", # "発表日"
      symbol: "symbol", # "ティッカーシンボル"
      dividend: "dividend", # "配当金"
      adj_dividend: "adjusted dividend", # "調整後配当金"
    }.freeze

    # https://financialmodelingprep.com/developer/docs#Company-Profile
    # https://financialmodelingprep.com/developer/docs/companies-key-stats-free-api
    def self.profile(symbol = "AAPL")
      res = Client.get url("/api/v3/profile/#{symbol}")
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
    end

    PROFILE_CONVERSION = {
      symbol: :symbol,
      price: :price,
      beta: :beta,
      volAvg: :volume_average,
      mktCap: :market_capitalization,
      lastDiv: :last_dividend,
      range: :range,
      changes: :changes,
      companyName: :company_name,
      currency: :currency,
      cik: :cik,
      isin: :isin,
      cusip: :cusip,
      exchange: :exchange,
      exchangeShortName: :exchange_short_name,
      industry: :industry,
      website: :website,
      description: :description,
      ceo: :ceo,
      sector: :sector,
      country: :country,
      fullTimeEmployees: :full_time_employees,
      phone: :phone,
      address: :address,
      city: :city,
      state: :state,
      zip: :zip,
      dcfDiff: :dcf_diff,
      dcf: :dcf,
      image: :image,
      ipoDate: :ipo_date,
      defaultImage: :default_image,
      isEtf: :is_etf,
      isActivelyTrading: :is_actively_trading,
    }


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

      query = {}
      query[:from] = from if from
      query[:to] = to if to
      query = Client.value_to_time query

      res = Client.get url(path, query)
      Client.parse_response_body(body: res.body, content_type: res["content-type"])
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
