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

  def new_dividend_of_dividend_aristocrats(title: "", x_axes: {}, left_y_axes: {}, right_y_axes: {})
    config = Config.new_dividend_of_dividend_aristocrats(
      title: title,
      labels: x_axes[:labels],
      y_left_label: left_y_axes[:label],
      y_left_data: left_y_axes[:data],
      y_right_label: right_y_axes[:label],
      y_right_data: right_y_axes[:data],
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
