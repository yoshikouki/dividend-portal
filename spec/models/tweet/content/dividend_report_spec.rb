# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tweet::Content::DividendReport, type: :model do
  describe "#new_dividend_of_dividend_aristocrats" do
    context "引数が空の場合" do
      let!(:base) do
        { date: "2021-08-17", label: "August 17, 21", record_date: "2021-08-18", payment_date: "2021-09-08", declaration_date: "2021-08-04",
          adj_dividend: 0.37, dividend: 0.37 }
      end
      let!(:historical_dividends_response) do
        { symbol: "ADM",
          historical: [base,
                       base.merge(date: "2021-05-18", dividend: 0.37),
                       base.merge(date: "2021-02-08", dividend: 0.37),
                       base.merge(date: "2020-11-18", dividend: 0.36),
                       base.merge(date: "2020-08-18", dividend: 0.36),
                       base.merge(date: "2020-05-19", dividend: 0.36),
                       base.merge(date: "2020-02-12", dividend: 0.36),
                       base.merge(date: "2019-11-20", dividend: 0.35),
                       base.merge(date: "2019-08-21", dividend: 0.35),
                       base.merge(date: "2019-05-14", dividend: 0.35),
                       base.merge(date: "2019-02-15", dividend: 0.35),
                       base.merge(date: "2018-11-21", dividend: 0.335)] }
      end

      it "素のテンプレートを返す" do
        allow(Client::Fmp).to receive(:historical_dividends).and_return(historical_dividends_response)
        content = Tweet::Content::DividendReport.new
        actual = content.new_dividend_of_dividend_aristocrats
        expected = "#配当貴族 $ の新着配当金情報です\n\n企業名 \n配当比率 % ($ )\n増配比率 % (+$ )\n増配年数 年\n配当支給日 \n権利付き最終日 \n配当性向 % (+%)\n"
        expect(actual).to eq expected
      end
    end
  end
end
