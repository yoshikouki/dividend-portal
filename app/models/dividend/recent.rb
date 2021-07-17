# frozen_string_literal: true

class Dividend::Recent < ApplicationRecord
  self.table_name =  "dividends"

  def self.update_to_latest
    latest_dividends = Dividend::Api.recent

    new_dividends = filter_new_dividends(latest_dividends)
    new_dividends
  end

  def self.filter_new_dividends(latest_dividends, current_dividends = all)
    latest_dividends.map do |latest_dividend|
      new = nil
      current_dividends.each do |current_dividend|
        new = latest_dividend unless current_dividend.same?(latest_dividend)
      end
      new
    end.compact
  end

  def same?(target_dividend)
    dividend == target_dividend.dividend &&
      symbol == target_dividend.symbol &&
      ex_dividend_on == target_dividend.ex_dividend_on
  end
end
