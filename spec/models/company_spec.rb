# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company, type: :model do
  describe "diff?" do
    context "同じ内容だった場合" do
      let!(:company) { FactoryBot.create(:company) }

      it "false を返す" do
        check_list = %i[
          name
          exchange
        ]
        same_company = Company.new(symbol: "WFC-PZ", name: "Wells Fargo & Company", exchange: "New York Stock Exchange")
        expect(company.diff?(same_company, check_list)).to be false
      end
    end
  end
end
