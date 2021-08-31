# frozen_string_literal: true

class Dividend
  module Calculation
    class << self
      # 計算上、最も古い2年分の配当は増配率が計算できないため削除する
      def dividend_growth_rate!(dividends)
        oldest_dividend_index = dividends.count - 1
        dividends_number_in_two_years = dividends.count % 4 == 1 ? 8 : 7
        dividends.filter_map.with_index do |dividend, i|
          next if (i + dividends_number_in_two_years) > oldest_dividend_index

          annual_dividend = annual_dividend(dividends, reference_index: i)
          last_annual_dividend = annual_dividend(dividends, reference_index: i + 4)
          dividend_growth_rate = (annual_dividend.to_d / last_annual_dividend.to_d - 1).to_f
          dividend.merge(dividend_growth_rate: dividend_growth_rate)
        end
      end

      private

      def annual_dividend(dividends, reference_index: 0, dividend_key: :adjusted_dividend)
        # 年4回の配当が前提の処理なので、配当貴族にそれ以外の企業があったら修正する
        dividends_in_one_year = dividends.slice(reference_index, 3)
        dividends_in_one_year.sum { |d| d[dividend_key].to_d }.to_f
      end
    end
  end
end
