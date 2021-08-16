# frozen_string_literal: true

module Tweet
  class Content
    class DividendReport < Tweet::Content
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
          # dividend_change: incremental_dividend_change,
          # incremental_dividend_rate: incremental_dividend_rate,
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
    end
  end
end
