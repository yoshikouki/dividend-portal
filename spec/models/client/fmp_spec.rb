# frozen_string_literal: true

require "rails_helper"

RSpec.describe Client::Fmp, type: :model do
  describe "#url" do
    valid_path = "/api/v3/stock/list"
    valid_path2 = "api/v3/stock/list"

    it "path should be valid" do
      expect(Client::Fmp.url(valid_path)).to be_truthy
    end

    it "path should be valid" do
      expect(Client::Fmp.url(valid_path2)).to be_truthy
    end

    context "query_hash がある場合" do
      it "URLの最後にクエリを生成する" do
        query_hash = {
          from: "test-from",
          to: "test-to",
        }
        url = Client::Fmp.url("test", query_hash)
        expect = "&from=test-from&to=test-to"
        expect(url.end_with?(expect)).to be_truthy
      end
    end
  end
end
