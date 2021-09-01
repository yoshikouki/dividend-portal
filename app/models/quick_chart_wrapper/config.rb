# frozen_string_literal: true

class QuickChartWrapper
  module Config
    NEW_DIVIDEND_OF_DIVIDEND_ARISTOCRATS = <<~CONFIG
      {
        type: "line",
        data: {
          labels: %%labels%%,
          datasets: [
            {
              type: "bar",
              label: "%%bar_title%%",
              data: %%bar_data%%,
              barPercentage: 1,
              categoryPercentage: 1,
              backgroundColor:"rgba(0,0,0, 0.1)",
              yAxisID: "right",
              },
            { 
              type: "line",
              label: "%%line_title%%",
              data: %%line_data%%,
              borderColor: "rgba(0, 0, 0, 0.1)",
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
                ticks: { fontSize: 20, fontFamily: "MONO", fontStyle: "bold" },
              },
            ],
            yAxes: [
              { 
                id: "left",
                position: "left",
                ticks: { fontSize: 20, fontFamily: "MONO", fontStyle: "bold" },
              },
              { 
                id: "right",
                position: "right",
                ticks: { beginAtZero: true, fontSize: 20, fontFamily: "MONO", fontStyle: "bold" }, 
                gridLines: { display: false },
              },
            ]
          },
          legend: {
            position: "bottom",
            labels: { fontSize: 20, fontFamily: "MONO", fontStyle: "bold" }
          },
          title: {
            text: "%%title%%",
            display: true,
            fontSize: 40,
            fontFamily: "MONO"
          }
        }
      }
    CONFIG
  end
end
