# frozen_string_literal: true

require "rails_helper"

describe "Fmp::PriceList" do
  describe ".historical" do
    context "シンボルが一つの場合" do
      it "シンボルの過去の株価をまとめた PriceList を返す" do
        VCR.use_cassette("models/fmp/price_list/historical") do
          price_list = Fmp::PriceList.historical("KO", from: "2021-09-01", to: "2021-09-03")
          expect(price_list).to be_instance_of Fmp::PriceList
          expect(price_list.responses.count).to eq 1
          expect(price_list.list.count).to eq 1
          expect(price_list.flatten.count).to eq 5
        end
      end
    end

    context "シンボルが最大5つまでの複数の場合" do
      it "複数のシンボルに関する過去の株価をまとめた PriceList インスタンスで返す" do
        VCR.use_cassette("models/fmp/price_list/historical_for_multiple_symbols") do
          price_list = Fmp::PriceList.historical(%w[KO JNJ PG XOM T IBM], from: "2021-09-01", to: "2021-09-03")
          expect(price_list).to be_instance_of Fmp::PriceList
          expect(price_list.responses.count).to eq 2
          expect(price_list.list.count).to eq 6
          expect(price_list.flatten.count).to eq 50
        end
      end
    end
  end
end
