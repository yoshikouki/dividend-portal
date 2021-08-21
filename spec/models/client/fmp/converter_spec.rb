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
        got = Client::Fmp::Converter.parse_response_body(body: body, content_type: "application/json;charset=UTF-8")
        expect(got).to eq(expect)
      end
    end

    context "response body が文字列の場合" do
      it "そのまま文字列を帰す" do
        body = "test response body"
        expect = "test response body"
        got = Client::Fmp::Converter.parse_response_body(body: body)
        expect(got).to eq(expect)
      end
    end
  end

  describe ".transform_keys_to_snake_case_and_symbol" do
    context "階層が混在している場合" do
      it "各要素のキーを変換して返す" do
        body = {
          "camelCase" => "string",
          "camelCase2" => [{ "camelCase" => "string" }, { "camelCase" => "string" }],
          "camelCase3" => { "camelCase" => "string", "camelCaseArray" => [{ "camelCase" => "string" }] },
        }
        actual = Client::Fmp::Converter.transform_keys_to_snake_case_and_symbol(body)
        expect = {
          camel_case: "string",
          camel_case2: [{ camel_case: "string" }, { camel_case: "string" }],
          camel_case3: { camel_case: "string", camel_case_array: [{ camel_case: "string" }] },
        }
        expect(actual).to eq(expect)
      end
    end
  end

  describe "value_to_time" do
    context "Hash の value が文字列だった場合" do
      it "value を %Y-%m-%d の形式に変換して返す" do
        cases = [
          {
            from: "2021-01-01",
            to: "2021-12-31",
          },
          {
            from: "20210101",
            to: "20211231",
          },
          {
            from: "210101",
            to: "211231",
          },
        ]
        expect = {
          from: "2021-01-01",
          to: "2021-12-31",
        }
        cases.each do |c|
          expect(Client::Fmp::Converter.value_to_time(c)).to eq(expect)
        end
      end
    end

    context "Hash の value が Time インスタンスだった場合" do
      it "インスタンスを %Y-%m-%d の形式に変換して返す" do
        cases = [
          {
            from: Time.parse("2021-01-01"),
            to: Time.parse("2021-12-31"),
          },
        ]
        expect = {
          from: "2021-01-01",
          to: "2021-12-31",
        }
        cases.each do |c|
          expect(Client::Fmp::Converter.value_to_time(c)).to eq(expect)
        end
      end
    end
  end
end
