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
                   data: [1, 2]
                 }]
    }
  }
  QUICK_CHART_DEFAULT_ARG = {
    width: 500,
    height: 300,
    background_color: '#ffffff',
    device_pixel_ratio: 2.0,
    format: 'png',
    key: nil
  }

  def mixed
    @client = QuickChart.new(QUICK_CHART_MIXED_CONFIG, **QUICK_CHART_DEFAULT_ARG)
    client.to_file(TEMP_IMAGE_PATH)
    File.new(TEMP_IMAGE_PATH)
  end
end
