# frozen_string_literal: true

class QuickChartWrapper
  module Config
    NEW_DIVIDEND_OF_DIVIDEND_ARISTOCRATS = <<~CONFIG
      {
        type: "line",
        data: {
          labels: %<labels>s,
          datasets: [
            {
              type: "bar",
              label: "%<bar_label>s",
              data: %<bar_data>s,
              barPercentage: 1,
              categoryPercentage: 1,
              backgroundColor:"rgba(0,0,0, 0.1)",
              yAxisID: "right",
              },
            {
              type: "line",
              label: "%<line_label>s",
              data: %<line_data>s,
              borderColor: "rgba(255, 159, 64, 0.1)",
              backgroundColor: getGradientFillHelper("vertical", [ "rgb(255, 159, 64)","rgba(255, 159, 64, 0.6)","rgba(255, 159, 64, 0.0)"]),
              pointRadius: 0,
              yAxisID: "left",
            },
          ]
        },
        options: {
          scales: {
            xAxes: [
              {
                gridLines: { display: false },
                ticks: { fontSize: #{FONT_SIZE}, fontFamily: "#{FONT_FAMILY}", fontStyle: "bold",
                        callback: (val) => {
                          let date = new Date(val.toLocaleString());
                          return date.getFullYear();
                        }},
              },
            ],
            yAxes: [
              {
                id: "left",
                position: "left",
                ticks: { fontSize: #{FONT_SIZE}, fontFamily: "#{FONT_FAMILY}", fontStyle: "bold",
                        callback: (val) => {
                          return val.toLocaleString() + "%%";
                        } },
              },
              {
                id: "right",
                position: "right",
                ticks: { beginAtZero: true, fontSize: #{FONT_SIZE}, fontFamily: "#{FONT_FAMILY}", fontStyle: "bold",
                        callback: (val) => {
                          let price = new Intl.NumberFormat("en-US", { style: "currency", currency: "USD", minimumFractionDigits: 2 });
                          return price.format(val.toLocaleString());
                        } },
                gridLines: { display: false },
              },
            ]
          },
          legend: {
            position: "bottom",
            labels: { fontSize: #{FONT_SIZE}, fontFamily: "#{FONT_FAMILY}", fontStyle: "bold" }
          },
          title: {
            text: "%<title>s",
            display: true,
            fontSize: #{FONT_SIZE * 2},
            fontFamily: "#{FONT_FAMILY}"
          }
        }
      }
    CONFIG

    class << self
      def new_dividend_of_dividend_aristocrats(**arg)
        format(
          NEW_DIVIDEND_OF_DIVIDEND_ARISTOCRATS,
          {
            title: arg[:title],
            labels: arg[:labels],
            line_label: arg[:y_left_label],
            line_data: arg[:y_left_data],
            bar_label: arg[:y_right_label],
            bar_data: arg[:y_right_data],
          },
        )
      end

      def line_chart_of_price(**arg)
        format(
          NEW_DIVIDEND_OF_DIVIDEND_ARISTOCRATS,
          {
            title: arg[:title],
            labels: arg[:labels],
            line_label: arg[:y_left_label],
            line_data: arg[:y_left_data],
            bar_label: arg[:y_right_label],
            bar_data: arg[:y_right_data],
          },
        )
      end
    end
  end
end
