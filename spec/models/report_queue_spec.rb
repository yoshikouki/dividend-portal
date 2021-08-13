# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportQueue, type: :model do
  describe ".enqueue" do
    context "正常系" do
      it "キューを追加する"
    end
  end

  describe ".dequeue" do
    context "正常系" do
      it "キューを取り出してレコードを削除する"
    end
  end
end
