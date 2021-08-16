# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::Content::DividendReport, type: :model do
  describe "#new_dividend_of_dividend_aristocrats" do
    context "引数が空の場合" do
      it "素のテンプレートを返す" do
        content = Tweet::Content::DividendReport.new
        actual = content.new_dividend_of_dividend_aristocrats
        expected = "#配当貴族 $ の新着配当金情報です\n\n企業名 \n配当比率 % ($ )\n増配比率 % (+$ )\n増配年数 年\n配当支給日 \n権利付き最終日 \n配当性向 % (+%)\n"
        expect(actual).to eq expected
      end
    end
  end
end
