# frozen_string_literal: true

class Dividend
  class Recent < ApplicationRecord
    self.table_name = "dividends"

    def self.refresh_us
      destroy_outdated
      result = update_us_to_latest
      enqueue_dividend_report(filter_id(result)) if result
    end

    # @return [ActiveRecord::Result, nil]
    def self.update_to_latest(latest_dividend_calendar)
      current_dividends = Dividend.order(:ex_dividend_on).to_a
      new_dividends = latest_dividend_calendar.filter_map do |latest|
        latest = remove_empty_string(latest)
        # dividends に保存されている配当の場合はスキップ
        current_index = current_dividends.find_index { |current| current.same?(latest) }
        if current_index
          current_dividends.delete_at(current_index) # 高速化のために削除しておく
          next
        end
        # companies に保存されていない企業の場合はスキップ
        unless latest[:company_id].present?
          latest[:company_id] = Company.find_by(symbol: latest[:symbol]) || next
        end

        Dividend::DEFAULT_INSERT_ALL.deep_dup.merge(latest)
      end

      return if new_dividends.empty?

      Dividend.insert_all!(new_dividends)
    end

    def self.update_us_to_latest
      latest_dividend_calendar = Api.recent
      dividend_calendar_in_us = associate_with_us_companies(latest_dividend_calendar)
      update_to_latest(dividend_calendar_in_us)
    end

    def self.destroy_outdated
      outdated = Dividend::Api::RECENT_REFERENCE_START_DATE.yesterday
      Dividend.where(ex_dividend_on: ..outdated).destroy_all
    end

    def self.enqueue_dividend_report(dividend_ids)
      ReportQueueOfDividendAristocratsDividend.enqueue(dividend_ids: dividend_ids)
    end

    def self.associate_with_us_companies(dividend_calendar = [])
      symbols = dividend_calendar.pluck(:symbol)
      companies_in_us = Company.in_us_where_or_create_by_symbol(symbols).to_a
      symbols_in_us = companies_in_us.pluck(:symbol)

      dividend_calendar.filter_map do |dc|
        symbol = dc[:symbol]
        index = symbols_in_us.find_index(symbol)
        if index
          symbols_in_us.delete_at(index)
          company = companies_in_us.delete_at(index)
          dc.merge(company_id: company.id)
        end
      end
    end

    def self.remove_empty_string(hash)
      # #present? ではfalse(boolean)だった場合もnilにしてしまうため、シンプルに空文字を検証する
      hash.transform_values { |v| v == "" ? nil : v }
    end

    def self.filter_id(result)
      result.map { |h| h["id"] }
    end
  end
end
