require 'rails_helper'

RSpec.describe Client::Fmp, type: :model do
  describe "#url" do
    valid_path = "/api/v3/stock/list"
    valid_path2 = "api/v3/stock/list"
    invalid_path = "//api/v3/stock/list"

    it "path should be valid" do
      expect(Client::Fmp.url(valid_path)).to be_truthy
    end

    it "path should be valid" do
      expect(Client::Fmp.url(valid_path2)).to be_truthy
    end
  end
end
