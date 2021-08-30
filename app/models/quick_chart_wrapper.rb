# frozen_string_literal: true

class QuickChartWrapper
  TEMP_IMAGE_PATH = "tmp/mixed_chart.png"

  # https://quickchart.io/documentation/
  QUICK_CHART_DEFAULT_ARG = {
    width: 500,
    height: 300,
    background_color: "#ffffff",
    device_pixel_ratio: 2.0,
    format: "png",
    key: nil,
  }.freeze

  def new_dividend_of_dividend_aristocrats(dividends)
    labels = dividends.pluck(:ex_dividend_on)
    datasets = [{ label: "一株当たり配当($)", data: dividends.pluck(:adjusted_dividend) }]
    data = data(labels, datasets)
    options = options(title: "$#{dividends[0][:symbol]} 過去25年間の推移")

    render config(:bar, data, options)
  end

  private

  def data(labels, datasets)
    { labels: labels,
      datasets: datasets }
  end

  def options(title: nil)
    options = {
      scales: {
        xAxes: [
          { gridLines: { display: false } },
        ],
        yAxes: [
          { ticks: { beginAtZero: true } },
        ],
      },
      legend: { position: "bottom" },
    }
    options.merge!(title_hash(title)) if title
    options
  end

  def title_hash(title)
    { title: {
      text: title,
      display: true,
      fontSize: 20,
      fontFamily: "Sans CJK JP"
      } }
  end

  def config(type, data, options)
    { type: type.to_s,
      data: data,
      options: options }
  end

  def render(config)
    client(config).to_file(TEMP_IMAGE_PATH)
    File.new(TEMP_IMAGE_PATH)
  end

  def client(config, arg: QUICK_CHART_DEFAULT_ARG)
    QuickChart.new(config, **arg)
  end
end
