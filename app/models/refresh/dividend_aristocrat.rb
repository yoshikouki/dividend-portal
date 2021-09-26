# frozen_string_literal: true

module Refresh
  module DividendAristocrat
    class << self
      # 配当貴族に関する網羅的な情報を更新する
      def general(target_start_date: "1900-01-01", dividend_aristocrats_symbols: ::Company::DividendAristocrat.symbols)
        # 2021年現在の配当貴族銘柄で企業情報を更新する
        ::Company.update_dividend_aristocrats(dividend_aristocrats_symbols: dividend_aristocrats_symbols)
        # 取得できる配当情報は 1962 年以降っぽいが念のため 1950 年で取得
        Refresh::Dividend.refresh(symbols: dividend_aristocrats_symbols, target_start_date: target_start_date)
        # 株式分割を保存する
        stock_split_calendar = Fmp::StockSplitCalendar.historical_for_bulk_symbols(dividend_aristocrats_symbols, from: target_start_date)
        ::StockSplit.insert_all_from_stock_split_calendar!(stock_split_calendar.to_stock_splits_attributes)
      end

      def weekly_prices(reference_date: Date.current)
        fpl = Fmp::PriceList.historical(::Company::DividendAristocrat.symbols,
                                        from: reference_date.beginning_of_week,
                                        to: reference_date.end_of_week)
        latest_prices = fpl.unstored_price_attributes
        Price.insert_all!(latest_prices) if latest_prices.present?
      end
    end
  end
end
