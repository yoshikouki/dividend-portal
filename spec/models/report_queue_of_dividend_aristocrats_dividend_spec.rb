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

  describe ".dequeue" do
    context "正常系" do
      let!(:no_dividend_aristocrats) { FactoryBot.create(:report_queue, :with_no_dividend_aristocrats_dividend) }
      let!(:dividend_aristocrats_queue) { FactoryBot.create(:report_queue_of_dividend_aristocrats_dividend, :with_dividend_aristocrats_dividend) }
      let!(:dividend_aristocrats_queue2) { FactoryBot.create(:report_queue_of_dividend_aristocrats_dividend, :with_dividend_aristocrats_dividend) }

      it "最新の配当貴族の配当レポートキューが一つ削除される" do
        queue = nil
        expect { queue = ReportQueueOfDividendAristocratsDividend.dequeue }.to change(ReportQueue, :count).by(-1)
        expect(queue).to eq(dividend_aristocrats_queue)
        expect(ReportQueue.all).to eq([no_dividend_aristocrats, dividend_aristocrats_queue2])
      end
    end

    context "配当貴族ではない配当レポートキューだけしかない場合" do
      let!(:no_dividend_aristocrats) { FactoryBot.create(:report_queue, :with_no_dividend_aristocrats_dividend) }

      it "キューは削除されない" do
        expect { ReportQueueOfDividendAristocratsDividend.dequeue }.to change(ReportQueue, :count).by(0)
      end
    end
  end
end
