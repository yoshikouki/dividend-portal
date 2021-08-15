# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::Content, type: :model do
  describe ".render" do
    context "引数が空の場合" do
      it "テストテンプレートをレンダーする" do
        actual = Tweet::Content.render
        expected = "@test is "
        expect(actual).to eq expected
      end
    end

    context "引数で変数を渡した場合" do
      it "引数に基づいてテストテンプレートをレンダーする" do
        actual = Tweet::Content.render(assigns: { test: "spec" })
        expected = "@test is spec"
        expect(actual).to eq expected
      end
    end

    context "引数でテンプレートのパスを渡した場合" do
      it "パスのテンプレートをレンダーする" do
        actual = Tweet::Content.render(template: "tweets/test")
        expected = "@test is "
        expect(actual).to eq expected
      end
    end
  end
end
