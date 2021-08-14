# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportQueueOfDividendAristocratsDividend, type: :model do
  describe ".create" do
    context "正常系" do
      let!(:dividend) { FactoryBot.create(:dividend, :with_company) }

      it "作成される" do
        expect { ReportQueueOfDividendAristocratsDividend.create(dividend_id: dividend.id) }.to change(ReportQueue, :count).by(1)
        expect(ReportQueue.first.type).to eq("ReportQueueOfDividendAristocratsDividend")
      end
    end
  end

  describe ".enqueue" do
    context "正常系" do
      let!(:dividend) { FactoryBot.create(:dividend, :with_dividend_aristocrats_company) }

      it "キューに追加される" do
        expect { ReportQueueOfDividendAristocratsDividend.enqueue(dividend_ids: [dividend.id]) }.to change(ReportQueue, :count).by(1)
        expect(ReportQueue.first.type).to eq("ReportQueueOfDividendAristocratsDividend")
      end
    end

    context "配当貴族ではない配当情報を渡した場合" do
      let!(:no_dividend_aristocrats) { FactoryBot.create(:dividend, :with_company) }

      it "キューには追加されない" do
        expect { ReportQueueOfDividendAristocratsDividend.enqueue(dividend_ids: no_dividend_aristocrats.id) }.to change(ReportQueue, :count).by(0)
      end
    end
  end
end
