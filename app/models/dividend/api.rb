class Dividend
  module Api
    def self.recent(from: nil, to: nil)
      from ||= Time.at(2.days.ago)
      row_dividends = Client::Fmp.get_dividend_calendar(
        from: from,
        to: to,
        )
      to_instances(row_dividends)
    end

    def self.to_instances(row_dividends = [])
      row_dividends.map do |dividend|
        Dividend.new(
          ex_dividend_on: dividend[:date],
          records_on: dividend[:record_date],
          pays_on: dividend[:payment_date],
          declares_on: dividend[:declaration_date],
          symbol: dividend[:symbol],
          dividend: dividend[:dividend],
          adjusted_dividend: dividend[:adj_dividend],
          )
      end
    end
  end
end
