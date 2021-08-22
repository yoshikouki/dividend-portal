# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportQueue, type: :model do
  describe ".dequeue" do
    context "正常系" do
      let!(:report_queue) { FactoryBot.create(:report_queue, dividend: FactoryBot.create(:dividend, :with_company)) }

      it "キューとして最初のレコードを削除する" do
        deleted_report_queue = ReportQueue.dequeue
        expect(ReportQueue.count).to eq(0)
        expect(deleted_report_queue).to eq(report_queue)
      end
    end
  end
end
