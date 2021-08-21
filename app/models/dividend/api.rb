# frozen_string_literal: true

class Dividend
  module Api
    RECENT_REFERENCE_START_DATE = Time.at(2.days.ago)

    CONVERSION_TABLE_OF_DIVIDEND_CALENDAR = {
      date: :ex_dividend_on,
      record_date: :records_on,
      payment_date: :pays_on,
      declaration_date: :declares_on,
      symbol: :symbol,
      dividend: :dividend,
      adj_dividend: :adjusted_dividend,
    }.freeze

    CONVERSION_TABLE_OF_OUTLOOK = {
      symbol: :symbol,
      price: :price,
      dividend_yield_ttm: :dividend_yield,
      dividend_per_share_ttm: :dividend_per_share,
      stock_dividend: :dividends, # stock_dividend (株式配当 ※通貨による配当ではない) ではなかったので改名
      payout_ratio_ttm: :payout_ratio
    }.freeze

    def self.recent(from: RECENT_REFERENCE_START_DATE, to: nil)
      row_dividends = Client::Fmp.get_dividend_calendar(
        from: from,
        to: to,
      )
      convert_response_of_dividend_calendar(row_dividends)
    end

    def self.convert_response_of_dividend_calendar(row_dividends = [])
      row_dividends.map do |dividend|
        # APIレスポンスがnullの祭に変換処理で空文字になることがあってバグになったので、明示的にnilに変換する
        dividend = dividend.transform_values { |v| v == "" ? nil : v }
        CONVERSION_TABLE_OF_DIVIDEND_CALENDAR.filter_map { |k, v| [v, dividend[k]] if dividend[k] }.to_h
      end
    end

    def self.all(symbols, from: nil, to: nil)
      historical_dividends = Client::Fmp.historical_dividends(
        symbols,
        from: from,
        to: to,
      )
      convert_response_of_historical_calendar(historical_dividends)
    end

    def self.convert_response_of_historical_calendar(historical_dividends)
      historical_dividends[:historical].map do |hd|
        # APIレスポンスがnullの祭に変換処理で空文字になることがあってバグになったので、明示的にnilに変換する
        hd = hd.transform_values { |v| v == "" ? nil : v }
        dividend = CONVERSION_TABLE_OF_DIVIDEND_CALENDAR.filter_map { |k, v| [v, hd[k]] if hd[k] }.to_h
        dividend.merge(symbol: historical_dividends[:symbol])
      end
    end

    def self.outlook(symbol)
      response = Client::Fmp.company_outlook(symbol)
      convert_response_of_company_outlook(response)
    end

    def self.convert_response_of_company_outlook(response)
      {
        symbol: response[:profile][:symbol],
        price: response[:profile][:price],
        ttm: {
          dividend_yield: response[:ratios].first[:dividend_yiel_ttm],
          dividend_per_share: response[:ratios].first[:dividend_per_share_ttm],
          payout_ratio: response[:ratios].first[:dividend_yiel_ttm],
        },
        dividends: response[:stock_dividend],
      }
    end
  end
end
