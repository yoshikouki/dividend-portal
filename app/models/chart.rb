# frozen_string_literal: true

class Chart
  attr_accessor :quick_chart_client

  def initialize(client: QuickChartWrapper.new)
    @quick_chart_client = client
  end

  def new_dividend_of_dividend_aristocrats(dividends)
    title = "$#{dividends[0][:symbol]} 過去25年間の推移"
    x = { labels: dividends.pluck(:ex_dividend_date) }
    y_left = { label: "増配率", data: dividends.pluck(:dividend_growth_rate).map { |rate| (rate * 100).round(2) } }
    y_right = { label: "一株当たり配当", data: dividends.pluck(:adjusted_dividend) }
    quick_chart_client.new_dividend_of_dividend_aristocrats(title: title, x_axes: x, left_y_axes: y_left, right_y_axes: y_right)
  end

  def line_chart_of_price(prices)
    prices = prices[-250..] if prices.length > 250 # 時系列順に並んでいることを前提とする
    title = "$#{prices[0].symbol} 株価 & 変動率"
    x = { labels: prices.pluck(:date).map { |d| d.strftime("%Y-%m-%d") } }
    y_left = { label: "株価", data: prices.pluck(:close) }
    y_right = { label: "変動率", data: prices.pluck(:change_percent) }
    quick_chart_client.line_chart_of_price(title: title, x_axes: x, left_y_axes: y_left, right_y_axes: y_right)
  end
end
