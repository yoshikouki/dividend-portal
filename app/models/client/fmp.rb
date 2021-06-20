# frozen_string_literal: true

module Client
  class Fmp < ApplicationRecord
    API_HOST = "financialmodelingprep.com"
    API_KEY = ENV["API_KEY_FMP"]

    def self.get_symbols_list
      Client.get url("/api/v3/stock/list")
    end

    def self.url(path)
      path = "/#{path}" if path[0] != "/"
      throw("Invalid pattern") if path[1] == "/"

      "https://#{API_HOST}#{path}?apikey=#{API_KEY}"
    end
  end
end