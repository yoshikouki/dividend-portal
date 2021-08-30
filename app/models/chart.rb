# frozen_string_literal: true

class Chart
  attr_accessor :quick_chart_client

  def initialize(client: QuickChartWrapper.new)
    @quick_chart_client = client
  end

  def new_dividend_of_dividend_aristocrats(dividends)
    dividends_in_chronological_order = dividends.reverse
    quick_chart_client.new_dividend_of_dividend_aristocrats(dividends_in_chronological_order)
  end
end
