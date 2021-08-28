class Chart
  attr_accessor :client

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
    client.to_file("tmp/mixed_chart.png")
  end
end
