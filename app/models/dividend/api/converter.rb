# frozen_string_literal: true

class Dividend
  module Api
    class Converter
      CONVERSION_TABLE_OF_DIVIDEND_CALENDAR = {
        date: :ex_dividend_date,
        record_date: :record_date,
        payment_date: :payment_date,
        declaration_date: :declaration_date,
        symbol: :symbol,
        dividend: :dividend,
        adj_dividend: :adjusted_dividend,
      }.freeze

      CONVERSION_TABLE_OF_OUTLOOK = {
        symbol: :symbol,
        price: :price,
        dividend_yield_ttm: :dividend_yield,
        dividend_per_share_ttm: :dividend_per_share,
        stock_dividend: :dividends, # stock_dividend (株式配当 ※通貨による配当ではない) ではなかったので改名
        payout_ratio_ttm: :payout_ratio,
      }.freeze

      ASSUMED_DIVIDEND_DECIMAL_POINT = 10

      def self.convert_response_of_dividend_calendar(row_dividends = [])
        row_dividends.map do |dividend|
          # APIレスポンスがnullの祭に変換処理で空文字になることがあってバグになったので、明示的にnilに変換する
          dividend = dividend.transform_values { |v| v == "" ? nil : v }
          CONVERSION_TABLE_OF_DIVIDEND_CALENDAR.filter_map { |k, v| [v, dividend[k]] if dividend[k] }.to_h
        end
      end

      def self.convert_response_of_historical_calendar(historical_dividends)
        historical_dividends[:historical].map do |hd|
          # APIレスポンスがnullの祭に変換処理で空文字になることがあってバグになったので、明示的にnilに変換する
          hd = hd.transform_values { |v| v == "" ? nil : v }
          dividend = CONVERSION_TABLE_OF_DIVIDEND_CALENDAR.filter_map { |k, v| [v, hd[k]] if hd[k] }.to_h
          dividend.merge(symbol: historical_dividends[:symbol])
        end
      end

      def self.convert_response_of_company_outlook(response)
        ratio = response[:ratios].first
        {
          symbol: response[:profile][:symbol],
          price: response[:profile][:price],
          ttm: {
            dividend_yield: ratio[:dividend_yield_ttm],
            dividend_per_share: ratio[:dividend_per_share_ttm].round(10), # たまに丸め誤差な数字も含まれるので、小数点第10位で四捨五入する
            payout_ratio: ratio[:payout_ratio_ttm],
          },
          dividends: response[:stock_dividend],
        }
      end

      def self.recalculate_adjusted_dividend(historical_dividends, historical_stock_splits)
        total_split_number_by_span = calculate_total_split_number(historical_stock_splits)
        calculate_adjusted_dividend_by_stock_split(historical_dividends, total_split_number_by_span)
      end

      def self.calculate_total_split_number(historical_stock_splits)
        total_split_number = 1
        stock_splits = historical_stock_splits.map do |split|
          split_date = Date.parse(split[:date])
          total_split_number *= split[:numerator]
          [split_date, total_split_number]
        end
        stock_splits.to_h
      end

      # total_split_number_by_span の配列は、最新情報を先頭に時系昇順で並んでいる想定 (必要があれば改修)
      def self.calculate_adjusted_dividend_by_stock_split(historical_dividends, total_split_number_by_span)
        historical_dividends.map do |dividend|
          ex_dividend_date = Date.parse(dividend[:ex_dividend_date])
          total_split_number_on_ex_dividend_date = total_stock_split_number(total_split_number_by_span, ex_dividend_date)
          dividend[:adjusted_dividend] = if total_split_number_on_ex_dividend_date > 1
            adjust_dividend(dividend, total_split_number_on_ex_dividend_date)
          else
            dividend[:adjusted_dividend].to_f
          end
          dividend
        end
      end

      def self.historical_stock_list(nested_historical_stock_list)
        stock_list = []
        nested_historical_stock_list[:historical_stock_list].each do |hash|
          stock_list += convert_response_of_historical_calendar(hash)
        end
        stock_list
      end

      class << self
        private

        def total_stock_split_number(total_split_number_by_span, ex_dividend_date)
          # 現在から権利落ち日まで間の最も古い株式分割
          oldest_stock_splits = total_split_number_by_span.keys.reverse.find { |split_date| split_date.after?(ex_dividend_date) }
          # 株式分割がなければ合計株式分割数は 1
          oldest_stock_splits ? total_split_number_by_span[oldest_stock_splits] : 1
        end

        def adjust_dividend(dividend, total_split_number)
          if dividend[:adjusted_dividend] == dividend[:dividend]
            division(dividend[:dividend], total_split_number)
          else
            # すでに調整済みの配当を選択する
            # ざっと4〜5社を調べた感じ、低いほうは株式分割を調整済みだった。何故か dividend に入る場合もある
            [dividend[:adjusted_dividend], dividend[:dividend]].min
          end
        end

        def division(numerator, denominator)
          result = numerator.to_d / denominator.to_d
          # result.to_s("F")[0..ASSUMED_DIVIDEND_DECIMAL_POINT]
          result.to_f
        end
      end
    end
  end
end
