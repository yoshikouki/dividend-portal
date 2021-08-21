# frozen_string_literal: true

module Client
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

      PROFILE_CONVERSION = {
        symbol: :symbol,
        price: :price,
        beta: :beta,
        vol_avg: :volume_average,
        mkt_cap: :market_capitalization,
        last_div: :last_dividend,
        range: :range,
        changes: :changes,
        company_name: :company_name,
        currency: :currency,
        cik: :cik,
        isin: :isin,
        cusip: :cusip,
        exchange: :exchange,
        exchange_short_name: :exchange_short_name,
        industry: :industry,
        website: :website,
        description: :description,
        ceo: :ceo,
        sector: :sector,
        country: :country,
        full_time_employees: :full_time_employees,
        phone: :phone,
        address: :address,
        city: :city,
        state: :state,
        zip: :zip,
        dcf_diff: :dcf_diff,
        dcf: :dcf,
        image: :image,
        ipo_date: :ipo_date,
        default_image: :default_image,
        is_etf: :is_etf,
        is_actively_trading: :is_actively_trading,
      }.freeze

      def self.parse_response_body(body:, content_type: nil)
        if content_type&.include?("application/json")
          body = JSON.parse(body)
          body = transform_keys_to_snake_case_and_symbol(body)
        end
        body
      end

      def self.symbols_to_param(symbols)
        param = symbols_to_s(symbols)
        # symbol に / を含むものが紛れており、エラーになるので変換する
        Converter.symbol_to_profile_query(param)
      end

      def self.symbol_to_profile_query(symbol)
        symbol.gsub(%r{[/_]}, "-")
      end

      def self.from_and_to_query(from, to)
        query = {}
        query[:from] = from if from
        query[:to] = to if to
        Client.value_to_time query
      end

      private

      def self.symbols_to_s(symbols)
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
