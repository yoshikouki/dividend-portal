# frozen_string_literal: true

module Refresh
  BEGINNING_OF_DIVIDEND_STORAGE_PERIOD = Time.at(1.days.ago)

  class << self
    def daily
      remove_for_saving_storage
      # TODO: 米国企業全ての配当金が保存されているので配当貴族のみに限定する
      new_dividend_ids = update_dividends
      enqueue(dividend_ids: new_dividend_ids) if new_dividend_ids.present?
      update_prices
    end

    def init
      Refresh::DividendAristocrat.general(target_start_date: Date.current.last_year)
    end

    def remove_for_saving_storage
      # TODO: 株価の保存期間を決めて超過した株価は削除する
    end

    def update_dividends
      result = self::Dividend.update_us
      filter_id(result)
    end

    def update_prices
      Refresh::DividendAristocrat.weekly_prices
    end

    def enqueue(dividend_ids: nil)
      self::Dividend.enqueue_dividend_report(dividend_ids)
    end

    private

    def filter_id(result)
      result.map { |h| h["id"] } if result.respond_to?(:map)
    end
  end
end
