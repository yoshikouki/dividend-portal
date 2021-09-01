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

  def new_dividend_of_dividend_aristocrats(title: "", x: {}, y_left: {}, y_right: {})
    config = Config.new_dividend_of_dividend_aristocrats(
      title: title,
      labels: x[:labels],
      y_left_label: y_left[:label],
      y_left_data: y_left[:data],
      y_right_label: y_right[:label],
      y_right_data: y_right[:data],
    )
    render config
  end

  private

  def render(config, path: TEMP_IMAGE_PATH)
    client(config).to_file(path)
    File.new(path)
  end

  def client(config, arg: QUICK_CHART_DEFAULT_ARG)
    QuickChart.new(config, **arg)
  end
end
