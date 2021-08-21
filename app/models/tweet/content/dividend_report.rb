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
        company = report_queue.dividend.company
        dividends = Dividend::Api.all(company.symbol, from: Time.at(3.years.ago))
        latest_dividend = dividends[0]
        outlook = Dividend::Api.outlook(company.symbol)

        changed_dividend = calculate_changed_dividend_and_its_rate_from_dividends(dividends)

        assigns = {
          symbol: company.symbol,
          name: company.name,
          years_of_dividend_growth: company.years_of_dividend_growth,
          dividend_per_share: latest_dividend[:dividend],
          pays_on: latest_dividend[:pays_on],
          ex_dividend_on: latest_dividend[:ex_dividend_on],
          changed_dividend: changed_dividend[:changed_dividend],
          changed_dividend_rate: changed_dividend[:changed_dividend_rate],
          dividend_yield: outlook[:ttm][:dividend_yield],
          annual_dividend_per_share: outlook[:ttm][:dividend_per_share],
          payout_ratio: outlook[:ttm][:payout_ratio],
        }
        self.class.render(
          template: template_path(__method__),
          assigns: assigns,
        )
      end

      # ttm は "trailing 12 months" 過去12ヶ月の実績
      def calculate_changed_dividend_and_its_rate_from_dividends(dividends)
        dividends_per_year = aggregate_by_12_months(dividends)
        calculate_changed_dividend_and_its_rate(dividends_per_year)
      end

      def aggregate_by_12_months(dividends, reference_date: Date.today)
        aggregated_results = {
          trailing_twelve_months_ago: DEFAULT_ANNUAL_DIVIDEND.dup,
          twelve_to_twenty_four_months_ago: DEFAULT_ANNUAL_DIVIDEND.dup,
        }
        twelve_months_ago = reference_date.months_ago(12)
        twenty_four_months_ago = reference_date.months_ago(24)

        dividends.each do |dividend_hash|
          ex_dividend_date = Date.parse(dividend_hash[:ex_dividend_on])
          target = if ex_dividend_date.after?(twelve_months_ago)
            :trailing_twelve_months_ago
          elsif ex_dividend_date.after?(twenty_four_months_ago)
            :twelve_to_twenty_four_months_ago
          end
          break unless target

          aggregated_results[target] = sum_dividend_to_hash(aggregated_results[target], dividend_hash)
        end
        aggregated_results
      end

      private

      def sum_dividend_to_hash(annualized_dividend_hash, dividend_hash)
        big_decimal = to_bd(annualized_dividend_hash[:annualized_dividend]) + to_bd(dividend_hash[:dividend])
        {
          annualized_dividend: big_decimal.to_f,
          dividend_count: annualized_dividend_hash[:dividend_count] += 1,
        }
      end

      def to_bd(float)
        BigDecimal(float, ASSUMED_DIVIDEND_DECIMAL_POINT)
      end

      def calculate_changed_dividend_and_its_rate(dividends_per_year)
        annualized_dividend = dividends_per_year[:trailing_twelve_months_ago][:annualized_dividend]
        previous_annualized_dividend = dividends_per_year[:twelve_to_twenty_four_months_ago][:annualized_dividend]
        {
          annualized_dividend: annualized_dividend,
          changed_dividend: to_bd(annualized_dividend) - to_bd(previous_annualized_dividend).to_f,
          changed_dividend_rate: (annualized_dividend / previous_annualized_dividend) - 1,
        }
      end
    end
  end
end
