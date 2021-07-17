# frozen_string_literal: true

class Dividend::Recent < ApplicationRecord
  self.table_name =  "dividends"

  def self.update_to_latest
    latest_dividends = Dividend::Api.recent

    latest_dividends.each do |dividend|
      Dividend.find_or_create_by(
        symbol: dividend.symbol,
        dividend: dividend.dividend,
        ex_dividend_on: dividend.ex_dividend_on,
        )
    end
  end
end
