# frozen_string_literal: true

require "rails_helper"

RSpec.describe Client::Fmp::Converter, type: :model do
  describe "parse_response_body" do
    context "response body がJSONかつkeyがキャメルケースの場合" do
      it "key がスネークケースに変換されたJSONを返す" do
        body = [{
                  "date" => "2021-07-09",
                  "label" => "July 09, 21",
                  "adjDividend" => 0.4025,
                  "symbol" => "OGE",
                  "dividend" => 0.4025,
                  "recordDate" => "2021-07-12",
                  "paymentDate" => "2021-07-30",
                  "declarationDate" => "2021-05-20",
                }].to_json
        expect = [{
                    adj_dividend: 0.4025,
                    date: "2021-07-09",
                    declaration_date: "2021-05-20",
                    dividend: 0.4025,
                    label: "July 09, 21",
                    payment_date: "2021-07-30",
                    record_date: "2021-07-12",
                    symbol: "OGE",
                  }]
        got = Client.parse_response_body(body: body, content_type: "application/json;charset=UTF-8")
        expect(got).to eq(expect)
      end
    end

    context "response body が文字列の場合" do
      it "そのまま文字列を帰す" do
        body = "test response body"
        expect = "test response body"
        got = Client.parse_response_body(body: body)
        expect(got).to eq(expect)
      end
    end
  end
end
