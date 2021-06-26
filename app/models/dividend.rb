module Dividend
  def self.recent
    Client::Fmp.get_dividend_calendar(
      from: Time.at(2.days.ago),
    )
  end
end
