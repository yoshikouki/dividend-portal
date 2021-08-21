# frozen_string_literal: true

module Tweet
  class Content
    class DividendReport < Tweet::Content
      DEFAULT_ANNUAL_DIVIDEND = {
        annualized_dividend: 0,
        dividend_count: 0,
      }.freeze
      ASSUMED_DIVIDEND_DECIMAL_POINT = 10
      PERCENTAGE_DECIMAL_POINT = 3

      def new_dividend_of_dividend_aristocrats(report_queue = nil)
        latest_dividend = report_queue.dividend
        company = latest_dividend.company
        dividends = Dividend::Api.all(latest_dividend.symbol, from: Time.at(3.years.ago))
        outlook = Dividend::Api.outlook(latest_dividend.symbol)

        total_result_of_this_year = total_result_of_this_year(dividends)

        assigns = {
          symbol: company.symbol,
          name: company.name,
          years_of_dividend_growth: company.years_of_dividend_growth,
          dividend_per_share: latest_dividend.dividend,
          pays_on: latest_dividend.pays_on,
          ex_dividend_on: latest_dividend.ex_dividend_on,
          dividend_change: total_result_of_this_year[:dividend_increase],
          incremental_dividend_rate: total_result_of_this_year[:incremental_dividend_rate],
          dividend_yield: outlook[:ttm][:dividend_yield],
          annual_dividend_per_share: outlook[:ttm][:dividend_per_share],
          payout_ratio: outlook[:ttm][:payout_ratio],
        }
        self.class.render(
          template: template_path(__method__),
          assigns: assigns,
        )
      end

      def total_result_of_this_year(dividends)
        annual_dividends = calculate_annually(dividends)
        calculate_total_result(annual_dividends, dividends.first)
      end

      def calculate_annually(dividends)
        annual_dividends = {}
        dividends.each do |dividend_hash|
          year = Date.parse(dividend_hash[:ex_dividend_on]).year
          annual_dividend = annual_dividends[year].presence || DEFAULT_ANNUAL_DIVIDEND.dup

          big_decimal = to_bd(annual_dividend[:annualized_dividend]) + to_bd(dividend_hash[:dividend])
          annual_dividend[:annualized_dividend] = big_decimal.to_f
          annual_dividend[:dividend_count] += 1

          annual_dividends[year] = annual_dividend
        end
        annual_dividends
      end

      def calculate_total_result(annual_dividends, latest_dividend)
        this_year = annual_dividends.keys.max
        annual_dividend_or_this_year = annual_dividends[this_year]

        # TODO: this_yearの配当支払いが終わっていない場合、推定の年間配当額を算出する
        # 昨年の年間配当
        # 昨年・一昨年の配当回数を取得して低い方を支払回数とみなす
        number_of_dividends_per_year = [annual_dividends[this_year - 1][:dividend_count], annual_dividends[this_year - 2][:dividend_count]].min
        # 今年の予想年間配当を計算する
        remained_number_of_dividends_per_year = number_of_dividends_per_year - annual_dividend_or_this_year[:dividend_count]
        forward_annual_dividend = annual_dividend_or_this_year[:dividend] + (remained_number_of_dividends_per_year * latest_dividend[:dividend])
        # 予想配当利回りを計算する
        current_price =
        forward_annual_dividend_rate = forward_annual_dividend / current_price
        last_year_annualized_dividend = annual_dividends[this_year - 1][:annualized_dividend]
        dividend_increase = (to_bd(annual_dividends[this_year][:annualized_dividend]) -
                             to_bd(last_year_annualized_dividend)).to_f
        incremental_dividend_rate = (dividend_increase / last_year_annualized_dividend).round(PERCENTAGE_DECIMAL_POINT)

        annual_dividend_or_this_year.merge(
          dividend_increase: dividend_increase,
          incremental_dividend_rate: incremental_dividend_rate,
        )
      end

      private

      def to_bd(float)
        BigDecimal(float, ASSUMED_DIVIDEND_DECIMAL_POINT)
      end

      def number_of_dividends_per_year
      end

      def calculate_forward_annual_dividend
      end
    end
  end
end
