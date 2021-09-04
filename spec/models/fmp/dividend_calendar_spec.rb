# frozen_string_literal: true

require "rails_helper"

describe "Fmp::DividendCalendar" do
  describe ".historical" do
    context "シンボルが一つの場合" do
      it "シンボルに関する過去の配当を返す" do
        VCR.use_cassette("models/fmp/dividend_calendar/historical") do
          actual = Fmp::DividendCalendar.historical("KO")
          expect(actual).to be_instance_of Fmp::DividendCalendar
          expect(actual.dividends.count).to eq 238
          expect(actual.dividends.first).to be_instance_of Fmp::Dividend
          expect(actual.dividends.last.symbol).to eq "KO"
          expect(actual.dividends.last.dividend).to eq 0.00156
        end
      end
    end

    context "シンボルが最大5つまでの複数の場合" do
      it "複数のシンボルに関する過去の配当を配列で返す" do
        VCR.use_cassette("models/fmp/dividend_calendar/historical_for_multiple_symbols") do
          actual = Fmp::DividendCalendar.historical("KO", "JNJ")
          expect(actual.dividends.count).to eq 41
          expect(actual.dividends.first.symbol).to eq "KO"
          expect(actual.dividends.last.symbol).to eq "JNJ"
        end
      end
    end
  end
end
