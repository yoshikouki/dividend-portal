# frozen_string_literal: true

class Dividend
  class Recent < ApplicationRecord
    self.table_name = "dividends"

    def self.refresh_us
      destroy_outdated
      update_us_to_latest
    end

    def self.update_to_latest(latest_dividend_calendar)
      current_dividends = Dividend.order(:ex_dividend_on).to_a
      new_dividends = latest_dividend_calendar.filter_map do |latest|
        latest = remove_empty_string(latest)
        # companies に保存されていない企業の場合は作成しない
        unless latest[:company_id].present?
          latest[:company_id] = Company.find_by(symbol: latest[:symbol]) || next
        end
        current_index = current_dividends.find_index { |current| current.same?(latest) }
        latest.merge(created_at: Time.current, updated_at: Time.current) unless current_index
      end

      Dividend.insert_all!(new_dividends) unless new_dividends.empty?
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
  end
end
