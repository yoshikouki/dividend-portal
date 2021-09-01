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

      def new_dividend_of_dividend_aristocrats(company, chart_start_on: Time.at(27.years.ago))
        dividends = Dividend::Api.all_adjusted(company.symbol, from: chart_start_on)
        outlook = Dividend::Api.outlook(company.symbol)
        assigns = convert_to_assigns(company, dividends, outlook)
        dividends_for_chart = dividends_for_chart(dividends)

        # コンテンツをレンダリング
        text = self.class.render(
          template: template_path(__method__),
          assigns: assigns,
        )
        image = Chart.new.new_dividend_of_dividend_aristocrats(dividends_for_chart)
        [text, image]
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
        # 各年で基準日(配当落ち日)の揺れがあって配当が別の年集計されてしまうことを防ぐため、月末を比較日とする
        # 2021年8月10日に配当支払いがあった場合、2020年9月1日以降の配当を過去12ヶ月分と計算する。
        # 日付比較で使う #after? は比較対象 Date を含まないので、一日古い日付を基準とするため #yesterday をつける
        reference_date_trailing_twelve_months = reference_date.months_ago(11).beginning_of_month.yesterday
        reference_date_twenty_four_months_ago = reference_date.months_ago(23).beginning_of_month.yesterday

        dividends.each do |dividend_hash|
          ex_dividend_date = Date.parse(dividend_hash[:ex_dividend_on])
          target = if ex_dividend_date.after?(reference_date_trailing_twelve_months)
            :trailing_twelve_months_ago
          elsif ex_dividend_date.after?(reference_date_twenty_four_months_ago)
            :twelve_to_twenty_four_months_ago
          end
          break unless target

          aggregated_results[target] = sum_dividend_to_hash(aggregated_results[target], dividend_hash)
        end
        aggregated_results
      end

      private

      def convert_to_assigns(company, dividends, outlook)
        latest_dividend = dividends[0]
        changed_dividend = calculate_changed_dividend_and_its_rate_from_dividends(dividends)
        {
          symbol: company.symbol,
          name: company.name,
          sector: company.sector,
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
      end

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

      def dividends_for_chart(dividends)
        merged_dividend_growth_rate = Dividend::Calculation.dividend_growth_rate!(dividends)
        dividends_in_chronological_order = merged_dividend_growth_rate.reverse
        dividends_in_chronological_order[0..99]
      end
    end
  end
end
