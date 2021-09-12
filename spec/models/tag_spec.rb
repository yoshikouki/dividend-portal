# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "validation" do
    context "正常系" do
      it "英数字とアンダースコアの識別子" do
        expect(Tag.new(name: :test_tag, display_name: "テスト用").valid?).to be true
      end

      it "一文字の識別子" do
        expect(Tag.new(name: :a, display_name: "1文字の識別子").valid?).to be true
      end

      it "先頭は英字のみ" do
        expect(Tag.new(name: :a1, display_name: "数字は先頭以外").valid?).to be true
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
