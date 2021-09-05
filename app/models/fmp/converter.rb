# frozen_string_literal: true

module Fmp
  module Converter
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

        "https://#{Client::API_HOST}#{path}?apikey=#{Client::API_KEY}#{query}"
      end

      def parse_response_body(response)
        if response["content-type"]&.include?("application/json")
          body = JSON.parse(response.body)
          transform_keys_to_snake_case_and_symbol(body)
        else
          response.body
        end
      end

      def transform_keys_to_snake_case_and_symbol(body)
        case body
        when Array
          body.map do |item, value|
            target = value || item
            case target
            when Array, Hash
              transform_keys_to_snake_case_and_symbol(target)
            else
              item.transform_keys { |key| key.underscore.to_sym }
            end
          end
        when Hash
          transformed_hash = body.map do |key, value|
            value = transform_keys_to_snake_case_and_symbol(value) if value.instance_of?(Array) || value.instance_of?(Hash)
            [key.underscore.to_sym, value]
          end
          transformed_hash.to_h
        end
      end

      def value_to_time(hash)
        hash.each do |key, value|
          case value
          when Time, Date
            # 何もしない
          else
            value = Time.parse(value)
          end
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

    def flatten_from_historical_hash(historical_hash)
      flattened = []
      if historical_hash.key?(:historical)
        dividends = historical_hash[:historical].map { |dividend| dividend.merge(symbol: historical_hash[:symbol]) }
        flattened = dividends
      elsif historical_hash.key?(:historical_stock_list)
        historical_hash[:historical_stock_list].each do |historical_dividends_by_symbol|
          flattened += flatten_from_historical_hash(historical_dividends_by_symbol)
        end
      end
      flattened
    end

    def remove_empty_string(arg)
      arg.transform_values { |v| v == "" ? nil : v }
    end
  end
end
