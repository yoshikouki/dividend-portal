# frozen_string_literal: true

require "rails_helper"

describe "Fmp::DividendCalendar" do
  describe ".historical" do
    context "シンボルが一つの場合" do
      it "シンボルに関する過去の配当 DividendCalendar インスタンスを返す" do
        VCR.use_cassette("models/fmp/dividend_calendar/historical") do
          actual = Fmp::DividendCalendar.historical("KO")
          expect(actual).to be_instance_of Fmp::DividendCalendar
          expect(actual.dividends.count).to eq 238
          expect(actual.dividends.first).to be_instance_of Fmp::Dividend
          expect(actual.dividends.first.date).to be_instance_of Date
          expect(actual.dividends.last.symbol).to eq "KO"
          expect(actual.dividends.last.dividend).to eq 0.00156
        end
      end
    end

    context "シンボルが最大5つまでの複数の場合" do
      it "複数のシンボルに関する過去の配当 DividendCalendar インスタンスを返す" do
        VCR.use_cassette("models/fmp/dividend_calendar/historical_for_multiple_symbols") do
          actual = Fmp::DividendCalendar.historical("KO", "JNJ")
          expect(actual.dividends.count).to eq 41
          expect(actual.dividends.first.symbol).to eq "KO"
          expect(actual.dividends.last.symbol).to eq "JNJ"
        end
      end
    end

    context "シンボルが6つ以上の場合" do
      it "複数のシンボルに関する配当金情報 DividendCalendar インスタンスを返す" do
        VCR.use_cassette("models/fmp/dividend_calendar/historical_for_multiple_symbols_over_6_symbols") do
          symbols = %w[KO JNJ PG XOM T IBM].sort
          dividend_calendar = Fmp::DividendCalendar.historical(symbols, from: "2021-06-01", to: "2021-09-26")
          expect(dividend_calendar).to be_instance_of Fmp::DividendCalendar
          expect(dividend_calendar.dividends.count).to eq 7 # KO が2回配当支給しているためシンボル数 +1
        end
      end
    end
  end
end
