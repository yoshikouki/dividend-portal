# frozen_string_literal: true

class QuickChartWrapper
  TEMP_IMAGE_PATH = "tmp/mixed_chart.png"

  FONT_SIZE = 20
  FONT_FAMILY = "MONO"
  # https://quickchart.io/documentation/
  QUICK_CHART_DEFAULT_ARG = {
    width: 1024,
    height: 576,
    background_color: "#ffffff",
    device_pixel_ratio: 2.0,
    format: "png",
  }.freeze

  def new_dividend_of_dividend_aristocrats(dividends)
    render QuickChartWrapper::Config::NEW_DIVIDEND_OF_DIVIDEND_ARISTOCRATS
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
          { gridLines: { display: false },
            ticks: { fontSize: FONT_SIZE, fontFamily: FONT_FAMILY, fontStyle: :bold } },
        ],
        yAxes: [
          { id: "left",
            position: "left",
            ticks: { fontSize: FONT_SIZE, fontFamily: FONT_FAMILY, fontStyle: :bold } },
          { id: "right",
            position: "right",
            ticks: { beginAtZero: true, fontSize: FONT_SIZE, fontFamily: FONT_FAMILY, fontStyle: :bold } },
        ],
      },
      legend: {
        position: "bottom",
        labels: { fontSize: FONT_SIZE, fontFamily: FONT_FAMILY, fontStyle: :bold },
      },
    }
    options.merge!(title_hash(title)) if title
    options
  end

  def title_hash(title)
    { title: {
      text: title,
      display: true,
      fontSize: FONT_SIZE * 2,
      fontFamily: FONT_FAMILY,
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
