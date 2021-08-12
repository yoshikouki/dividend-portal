require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe "validation" do
    context "正常系" do
      it "valid" do
        [
          {name: :dividend_aristocrats, display_name: "配当貴族"},
          {name: :aa, display_name: "テスト"},
        ].each do |attr|
          expect(Tag.new(attr).valid?).to be true
        end
      end
    end

    context "異常系" do
      it "invalid" do
        [
          { name: :aa, display_name: "" },
          { name: :a, display_name: "2文字以下の識別子" },
          { name: :_a, display_name: "アンダーバーから始まる" },
          { name: :a_, display_name: "アンダーバーで終わる" },
          { name: "a-a", display_name: "アンダーバー以外の記号" },
        ].each do |attr|
          expect(Tag.new(attr).valid?).to be false
        end
      end
    end
  end
end
