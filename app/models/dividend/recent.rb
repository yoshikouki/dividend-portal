# frozen_string_literal: true

class Dividend
  class Recent < ApplicationRecord
    self.table_name = "dividends"

    def self.refresh_us
      destroy_outdated
      update_us_to_latest
    end

    def self.update_to_latest(latest_dividends = Dividend::Api.recent)
      current_dividends = Dividend.order(:ex_dividend_on).to_a
      new_dividends = latest_dividends.filter_map do |latest|
        latest = remove_empty_string(latest)
        current_index = current_dividends.find_index { |current| current.same?(latest) }
        latest.merge(created_at: Time.current, updated_at: Time.current) unless current_index
      end

      Dividend.insert_all!(new_dividends) unless new_dividends.empty?
    end

    def self.update_us_to_latest
      dividend_calendars = Api.recent
      latest_dividends = filter_by_us(dividend_calendars)
      update_to_latest(latest_dividends)
    end

    def self.destroy_outdated
      outdated = Time.at(3.days.ago)
      Dividend.where(ex_dividend_on: ..outdated).destroy_all
    end

    def self.filter_by_us(dividend_calendars = [])
      symbols = dividend_calendars.pluck(:symbol)
      symbols_in_us = Company.in_us_where_or_create_by_symbol(symbols).pluck(:symbol)
      dividend_calendars.filter { |dc| symbols_in_us.include?(dc[:symbol]) }
    end

    def self.remove_empty_string(hash)
      # #present? ではfalse(boolean)だった場合もnilにしてしまうため、シンプルに空文字を検証する
      hash.transform_values { |v| v == "" ? nil : v }
    end
  end
end
