# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "validation" do
    context "正常系" do
      it "valid" do
        [
          { name: :dividend_aristocrats, display_name: "配当貴族" },
          { name: :a, display_name: "1文字の識別子" },
          { name: :a1, display_name: "数字は先頭以外" },
        ].each do |attr|
          expect(Tag.new(attr).valid?).to be true
        end
      end
    end

    context "異常系" do
      it "invalid" do
        [
          { name: :empty_display_name, display_name: "" },
          { name: :_a, display_name: "アンダーバーから始まる" },
          { name: :a_, display_name: "アンダーバーで終わる" },
          { name: "a-a", display_name: "アンダーバー以外の記号" },
          { name: "1a", display_name: "先頭に数字" },
        ].each do |attr|
          expect(Tag.new(attr).valid?).to be false
        end
      end
    end
  end
end
