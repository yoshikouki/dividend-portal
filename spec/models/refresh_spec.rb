# frozen_string_literal: true

require "rails_helper"

describe "Refresh APIから情報を取得してDBを最新情報にアップデートする" do
  describe ".dividend_aristocrats 配当貴族に関する情報を最新にする" do
    it "情報がなかった場合、新しく作られる" do
      VCR.use_cassette("models/refresh/dividend_aristocrats") do
        expect { Refresh.dividend_aristocrats }
          .to change { Dividend.count }.by(10_639)
                                       .and change { Company.count }.by(65)
                                                                    .and change { StockSplit.count }.by(364)
      end
    end
  end
end
