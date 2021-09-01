# frozen_string_literal: true

class Chart
  attr_accessor :quick_chart_client

  def initialize(client: QuickChartWrapper.new)
    @quick_chart_client = client
  end

  def new_dividend_of_dividend_aristocrats(dividends)
    title = "$#{dividends[0][:symbol]} 過去25年間の推移"
    x = { labels: dividends.pluck(:ex_dividend_on) }
    y_left = { label: "増配率", data: dividends.pluck(:dividend_growth_rate).map { |rate| (rate * 100).round(2) } }
    y_right = { label: "一株当たり配当", data: dividends.pluck(:adjusted_dividend) }
    quick_chart_client.new_dividend_of_dividend_aristocrats(title: title, x_axes: x, left_y_axes: y_left, right_y_axes: y_right)
  end
end
