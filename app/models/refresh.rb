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

    def dividend_aristocrats
      # 配当貴族に関する網羅的な情報を更新する
      # 定期的な実行ではない
      # 現在、グラフなどの不具合を出てきたら修正するスタイルになっているので、一度情報を揃えて検証したい
      # 分析・検証用に情報を揃えたい
    end

    private

    def filter_id(result)
      result.map { |h| h["id"] } if result.respond_to?(:map)
    end
  end
end
