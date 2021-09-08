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

      assign_list
    end

    def flatten
      return @flatten_list if @flatten_list

      assign_flatten_list
    end

    private

    def assign_list
      @list = {}
      convert_historical_responses_to(@list)
    end

    def assign_flatten_list
      @flatten_list = []
      convert_historical_responses_to(@flatten_list)
    end

    def convert_historical_responses_to(instance_variable)
      convert_method = convert_method(instance_variable)
      @responses.each do |response|
        if response.key?(:historical)
          send(convert_method, instance_variable, response)
        elsif response.key?(:historical_stock_list)
          response[:historical_stock_list].each do |stock_list|
            send(convert_method, instance_variable, stock_list)
          end
        end
      end
      instance_variable
    end

    def convert_method(instance_variable)
      case instance_variable
      when @list
        :symbol_as_key
      when @flatten_list
        :merged_symbol
      end
    end

    def symbol_as_key(list, response)
      key = response[:symbol]
      list[key] = response[:historical]
    end

    def merged_symbol(flatten_list, response)
      response[:historical].each { |price| flatten_list.push price.merge(symbol: response[:symbol]) }
    end
  end
end
