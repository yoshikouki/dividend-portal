# frozen_string_literal: true

module Client
  class Fmp < ApplicationRecord
    API_HOST = "financialmodelingprep.com"
    API_KEY = ENV["API_KEY_FMP"]

    START_DATE_OF_RECENT_DIVIDEND= Time.now.ago(3.days)

    def self.get_symbols_list
      Client.get url("/api/v3/stock/list")
    end

    def self.get_dividend_calendar(from: nil, to: nil)
      path = "/api/v3/stock_dividend_calendar"

      query = {}
      query[:from] = from ? from : START_DATE_OF_RECENT_DIVIDEND
      query[:to] = to if to
      query = Client.value_to_time query

      Client.get url(path, query)
    end

    def self.url(path, query_hash = {})
      path = "/#{path}" if path[0] != "/"
      throw("Invalid pattern") if path[1] == "/"

      query = ""
      unless query_hash.empty?
        query += "&"
        query_hash.each do |key, value|
          query += "#{key.to_s}=#{value.to_s}"
        end
      end

      "https://#{API_HOST}#{path}?apikey=#{API_KEY}#{query}"
    end
  end
end
