# frozen_string_literal: true

module Fmp
  class PriceList
    extend Fmp::Converter

    attr_reader :flatten_list, :responses

    CONVERSION_TABLE_OF_PRICE = {
      date: :date,
      open: :open,
      high: :high,
      low: :low,
      close: :close,
      adjusted_close: :adj_close,
      volume: :volume,
      unadjusted_volume: :unadjusted_volume,
      change: :change,
      change_percent: :change_percent,
      vwap: :vwap,
      change_over_time: :change_over_time,
      symbol: :symbol,
    }.freeze

    def self.historical(*symbols, from: nil, to: nil, timeseries: nil, serietype: nil)
      price_list = new
      symbols.flatten.each_slice(5) do |up_to_5_symbols|
        price_list.responses << Fmp.historical_prices(up_to_5_symbols, from: from, to: to, timeseries: timeseries, serietype: serietype)
      end
      price_list
    end

    def initialize(responses = [])
      @responses = responses
    end

    def prices
      @dividend_calendar
    end

    def list
      return @list if @list

      assign_list
    end

    def flatten
      return @flatten_list if @flatten_list

      assign_flatten_list
      sort_by_date!(@flatten_list)
    end

    def to_prices_attributes
      flatten.map { |price| CONVERSION_TABLE_OF_PRICE.filter_map { |after, before| [after, price[before]] }.to_h }
    end

    def unstored_price_attributes
      from = flatten.first[:date].to_date
      to = flatten.last[:date].to_date
      stored_prices = Price.where(date: from..to).select(:date, :symbol).pluck(:date, :symbol)
      flatten.filter_map do |price|
        next if stored_prices.delete([price[:date].to_date, price[:symbol]])

        CONVERSION_TABLE_OF_PRICE.filter_map { |after, before| [after, price[before]] }.to_h
      end
    end

    def to_price_history
      ::Price::History.new(prices: to_prices_attributes)
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

    def sort_by_date!(instance_variable)
      instance_variable.sort_by! { |price| price[:date].to_date }
    end
  end
end
