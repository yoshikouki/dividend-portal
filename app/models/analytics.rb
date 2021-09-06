# frozen_string_literal: true

class Analytics
  attr_accessor :resource, :latest_dividend_growth

  def initialize(resource: [])
    @resource = resource
  end

  class << self
    def dividend_growth_rate
      symbols = Company::DIVIDEND_ARISTOCRATS
      analytics = new
      symbols.map.with_index do |symbol,i|
        analytics.resource << Fmp.financial_growth(symbol, period: :annual).first
      end
      analytics.latest_dividend_growth = analytics.resource.map do |growth|
        {
          one: (growth[:dividendsper_share_growth] * 100).round(2),
          three: (growth[:three_y_dividendper_share_growth_per_share] * 100).round(2),
          five: (growth[:five_y_dividendper_share_growth_per_share] * 100).round(2),
          ten: (growth[:ten_y_dividendper_share_growth_per_share] * 100).round(2),
          symbol: growth[:symbol],
          date: growth[:date],
          period: growth[:period],
        }
      end
      analytics
    end
  end
end

