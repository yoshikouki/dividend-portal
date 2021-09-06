# frozen_string_literal: true

module Fmp
  class PriceList
    extend Fmp::Converter

    attr_reader :flatten_list, :responses

    def initialize(responses = [])
      @responses = responses
    end

    def prices
      @dividend_calendar
    end

    def self.historical(*symbols, from: nil, to: nil, timeseries: nil, serietype: nil)
      price_list = new
      symbols.flatten.each_slice(5) do |up_to_5_symbols|
        price_list.responses << Fmp.historical_prices(up_to_5_symbols, from: from, to: to, timeseries: timeseries, serietype: serietype)
      end
      price_list
    end

    def list
      return @list if @list

      @list = {}
      @responses.each do |response|
        if response.key?(:historical)
          key = response[:symbol]
          @list[key] = response[:historical]
        else
          response[:historical_stock_list].each do |stock_list|
            key = stock_list[:symbol]
            @list[key] = stock_list[:historical]
          end
        end
      end
      @list
    end

    def flatten
      return @flatten_list if @flatten_list

      @flatten_list = @responses
    end
  end
end
