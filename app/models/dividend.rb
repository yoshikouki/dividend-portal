module Dividend
  def self.recent(from: nil, to: nil)
    Client::Fmp.get_dividend_calendar(
      from: from || Time.at(2.days.ago),
      to: to || Time.now,
    )
  end
end
