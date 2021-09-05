# frozen_string_literal: true

module Refresh
  BEGINNING_OF_DIVIDEND_STORAGE_PERIOD = Time.at(1.days.ago)

  class << self
    def daily
      remove_for_saving_storage
      new_dividend_ids = update_dividends
      enqueue(dividend_ids: new_dividend_ids) if new_dividend_ids.present?
    end

    def remove_for_saving_storage
      self::Dividend.remove_outdated
    end

    def update_dividends
      result = self::Dividend.update_us
      filter_id(result)
    end

    def enqueue(dividend_ids: nil)
      self::Dividend.enqueue_dividend_report(dividend_ids)
    end

    # 配当貴族に関する網羅的な情報を更新する
    def dividend_aristocrats
      dividend_aristocrats_symbols = Company::DIVIDEND_ARISTOCRATS
      # 2021年現在の配当貴族銘柄で企業情報を更新する
      ::Company.update_dividend_aristocrats(dividend_aristocrats_symbols: dividend_aristocrats_symbols)
      # 取得できる配当情報は 1962 年以降っぽいが念のため 1950 年で取得
      dividend_calendar = Fmp::DividendCalendar.historical_for_bulk_symbols(dividend_aristocrats_symbols, from: "1950-01-01")
      Dividend.insert_all_from_dividend_calendar!(dividend_calendar, associate_company: false)
      # 株式分割を保存する
    end

    private

    def filter_id(result)
      result.map { |h| h["id"] } if result.respond_to?(:map)
    end
  end
end
