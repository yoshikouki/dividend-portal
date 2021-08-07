# frozen_string_literal: true

class Dividend
  class Recent < ApplicationRecord
    self.table_name = "dividends"

    def self.update_to_latest(latest_dividends = Dividend::Api.recent)
      latest_dividends.each do |dividend|
        Dividend.find_or_create_by(dividend)
      end
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
  end
end
