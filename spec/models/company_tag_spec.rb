require 'rails_helper'

RSpec.describe CompanyTag, type: :model do
  describe "validation" do
    context "正常系" do
      let!(:company) {FactoryBot.create(:company) }
      let!(:tag) {FactoryBot.create(:tag) }

      it "valid" do
        expect(CompanyTag.new(company: company, tag: tag).valid?).to be true
      end
    end
  end
end
