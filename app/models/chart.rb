# frozen_string_literal: true

class Chart
  attr_accessor :client

  TEMP_IMAGE_PATH = "tmp/mixed_chart.png"

  # https://quickchart.io/documentation/
  QUICK_CHART_MIXED_CONFIG = {
    type: "bar",
    data: {
      labels: ["Hello world", "Test"],
      datasets: [{
        label: "Foo",
        data: [1, 2],
      }],
    },
  }.freeze
  QUICK_CHART_DEFAULT_ARG = {
    width: 500,
    height: 300,
    background_color: "#ffffff",
    device_pixel_ratio: 2.0,
    format: "png",
    key: nil,
  }.freeze

  def mixed
    client.to_file(TEMP_IMAGE_PATH)
    File.new(TEMP_IMAGE_PATH)
  end

  private

  def client(config: QUICK_CHART_MIXED_CONFIG, arg: QUICK_CHART_DEFAULT_ARG)
    @client ||= QuickChart.new(config, **arg)
  end
end
