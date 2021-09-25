# frozen_string_literal: true

require "rails_helper"

describe "QuickChartWrapper::Config" do
  describe ".new_dividend_of_dividend_aristocrats" do
    let!(:expected_config) do
      <<~CONFIG
        {
          type: "line",
          data: {
            labels: ["2020-08-18", "2020-11-18", "2021-02-08", "2021-05-18", "2021-08-17"],
            datasets: [
              {
                type: "bar",
                label: "一株当たり配当",
                data: [0.36, 0.36, 0.37, 0.37, 0.37],
                barPercentage: 1,
                categoryPercentage: 1,
                backgroundColor:"rgba(0,0,0, 0.1)",
                yAxisID: "right",
                },
              {
                type: "line",
                label: "増配率",
                data: [2.86, 2.86, 2.83, 2.8, 2.78],
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
                  ticks: { fontSize: 20, fontFamily: "MONO", fontStyle: "bold",
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
                  ticks: { fontSize: 20, fontFamily: "MONO", fontStyle: "bold",
                          callback: (val) => {
                            return val.toLocaleString() + "%";
                          } },
                },
                {
                  id: "right",
                  position: "right",
                  ticks: { beginAtZero: true, fontSize: 20, fontFamily: "MONO", fontStyle: "bold",
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
              labels: { fontSize: 20, fontFamily: "MONO", fontStyle: "bold" }
            },
            title: {
              text: "$ADM 過去25年間の推移",
              display: true,
              fontSize: 40,
              fontFamily: "MONO"
            }
          }
        }
      CONFIG
    end

    it "QuickChart のコンフィグをテキストで返す" do
      config = QuickChartWrapper::Config.new_dividend_of_dividend_aristocrats(
        title: "$ADM 過去25年間の推移",
        labels: %w[2020-08-18 2020-11-18 2021-02-08 2021-05-18 2021-08-17],
        y_left_label: "増配率",
        y_left_data: [2.86, 2.86, 2.83, 2.8, 2.78],
        y_right_label: "一株当たり配当",
        y_right_data: [0.36, 0.36, 0.37, 0.37, 0.37],
      )
      expect(config).to eq(expected_config)
    end
  end
end
