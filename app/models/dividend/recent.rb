# frozen_string_literal: true

class Dividend
  class Recent < ApplicationRecord
    self.table_name = "dividends"

    def self.update_to_latest(latest_dividends = Dividend::Api.recent)
      current_dividends = Dividend.where(ex_dividend_on: Date.today..).order(:ex_dividend_on).to_a

      new_dividends = []
      updated_dividends = []
      latest_dividends.each do |latest|
        latest = remove_empty_string(latest)
        current_index = current_dividends.find_index { |current| current.same?(latest) }
        unless current_index
          new_dividends << Dividend.attributes_hash(latest)
          next
        end

        current_dividend = current_dividends.delete_at(current_index)
        next unless current_dividend.updated?(latest)

        updated_dividends << Dividend.attributes_hash(latest, current_dividend)
      end

      Dividend.insert_all!(new_dividends) unless new_dividends.empty?
      Dividend.update_all(updated_dividends) unless updated_dividends.empty?
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
