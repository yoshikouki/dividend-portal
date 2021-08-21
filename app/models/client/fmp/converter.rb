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
    end
  end
end
