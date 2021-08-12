require 'rails_helper'

RSpec.describe CompanyTag, type: :model do
  describe "validation" do
    context "正常系" do
      let!(:company) {FactoryBot.create(:company) }
      let!(:tag) {FactoryBot.create(:tag) }

      it "valid" do
        expect(CompanyTag.new(company: company, tag: tag).valid?).to be true
      end

      it "Company--Tag のペアはユニーク" do
        CompanyTag.create(company: company, tag: tag)
        expect{ CompanyTag.create(company: company, tag: tag) }.to change(CompanyTag, :count).by(0)
      end
    end
  end
end
