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

        annual_dividends = annualized_dividends(dividends)

        assigns = {
          symbol: company.symbol,
          name: company.name,
          years_of_dividend_growth: company.years_of_dividend_growth,
          dividend: latest_dividend.dividend,
          pays_on: latest_dividend.pays_on,
          ex_dividend_on: latest_dividend.ex_dividend_on,
          dividend_change: annual_dividends[Time.current.year][:dividend_increase],
          incremental_dividend_rate: annual_dividends[Time.current.year][:incremental_dividend_rate],
          # dividend_yield: dividend_yield,
          # company-key-metrics-api などで取得できそうだが工数かかるので後回し
          # payout_ratio: payout_ratio,
          # payout_ratio_change: payout_ratio_change,
        }
        self.class.render(
          template: template_path(__method__),
          assigns: assigns,
        )
      end

      def annualized_dividends(dividends)
        annual_dividends = calculate_annually(dividends)
        add_dividend_increase(annual_dividends)
      end

      def calculate_annually(dividends)
        annual_dividends = {}
        dividends.each do |dividend_hash|
          year = Date.parse(dividend_hash[:ex_dividend_on]).year
          annual_dividend = annual_dividends[year].presence || DEFAULT_ANNUAL_DIVIDEND.dup

          big_decimal = BigDecimal(annual_dividend[:annualized_dividend], ASSUMED_DIVIDEND_DECIMAL_POINT) + BigDecimal(dividend_hash[:dividend], ASSUMED_DIVIDEND_DECIMAL_POINT)
          annual_dividend[:annualized_dividend] =  big_decimal.to_f
          annual_dividend[:dividend_count] += 1

          annual_dividends[year] = annual_dividend
        end
        annual_dividends
      end

      def add_dividend_increase(annual_dividends)
        this_year = annual_dividends.keys.max
        last_year_annualized_dividend = annual_dividends[this_year - 1][:annualized_dividend]
        dividend_increase = annual_dividends[this_year][:annualized_dividend] - last_year_annualized_dividend
        annual_dividends[this_year][:dividend_increase] = dividend_increase
        annual_dividends[this_year][:incremental_dividend_rate] = (dividend_increase / last_year_annualized_dividend).round(PERCENTAGE_DECIMAL_POINT)
        annual_dividends
      end
    end
  end
end
