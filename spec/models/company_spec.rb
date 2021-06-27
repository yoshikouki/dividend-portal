# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company, type: :model do
  describe "diff?" do
    context "同じ内容だった場合" do
      it "false を返す" do
        arg = {
          symbol: "TEST",
          name: "name",
          exchange: "exchange",
        }
        check_list = %i[
          name
          exchange
        ]
        company = Company.new(arg)
        same_company = Company.new(arg)
        expect(company.diff?(same_company, check_list)).to be_falsey
      end
    end
  end
end
