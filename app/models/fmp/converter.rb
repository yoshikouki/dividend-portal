# frozen_string_literal: true

module Fmp
  module Converter
    API_HOST = "financialmodelingprep.com"
    API_KEY = ENV["API_KEY_FMP"]

    DIVIDEND_CALENDAR_FOR_VIEW = {
      date: "ex-dividend date", # "権利落ち日"
      label: "label", # "権利落ち日(英語表記)"
      record_date: "record date", # "権利確定日"
      payment_date: "payment date", # "支払日"
      declaration_date: "declaration date", # "発表日"
      symbol: "symbol", # "ティッカーシンボル"
      dividend: "dividend", # "配当金"
      adj_dividend: "adjusted dividend", # "調整後配当金"
    }.freeze

    class << self
      def url(path, query_hash = {})
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

      def parse_response_body(body:, content_type: nil)
        if content_type&.include?("application/json")
          body = JSON.parse(body)
          body = transform_keys_to_snake_case_and_symbol(body)
        end
        body
      end

      def transform_keys_to_snake_case_and_symbol(body)
        # TODO: 孫子要素が[{}]の階層を持っていると変換されないので、必要になったら修正する
        case body
        when Array
          body.map do |item, value|
            case value
            when Array, Hash
              transform_keys_to_snake_case_and_symbol(value)
            else
              item.transform_keys { |key| key.underscore.to_sym }
            end
          end
        when Hash
          transformed_hash = body.map do |key, value|
            case value
            when Array, Hash
              value = transform_keys_to_snake_case_and_symbol(value)
            end
            [key.underscore.to_sym, value]
          end
          transformed_hash.to_h
        end
      end

      def value_to_time(hash)
        hash.each do |key, value|
          value = Time.parse(value) unless value.instance_of? Time
          hash[key] = value.strftime("%Y-%m-%d")
        end
      end

      def symbols_to_param(symbols)
        param = symbols_to_s(symbols)
        # symbol に / を含むものが紛れており、エラーになるので変換する
        symbol_to_profile_query(param)
      end

      def symbol_to_profile_query(symbol)
        symbol.gsub(%r{[/_]}, "-")
      end

      def from_and_to_query(from, to)
        query = {}
        query[:from] = from if from
        query[:to] = to if to
        value_to_time query
      end

      def symbols_to_s(symbols)
        case symbols
        when Array
          symbols.join(",")
        when String
          symbols
        end
      end
    end
  end
end

