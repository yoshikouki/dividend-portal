# frozen_string_literal: true

module Tweet
  class Content
    module Template
      SYMBOL_PREFIX = "$"
      SYMBOL_DELIMITER = " "

      def self.dividend_ex_dividend_previous_date(count = 0, date)
        Content.new(
          header: "権利付き最終日通知",
          main: "#{date.show}までの購入で配当金が受け取れる米国株は#{count}件です",
        )
      end

      def self.dividend_latest_dividend(count = 0, date)
        Content.new(
          header: "配当金新着情報",
          main: "#{date.show}の新着情報は #{count}件です",
        )
      end

      def self.symbol(symbol)
        Template::SYMBOL_PREFIX + symbol
      end

      def self.symbols_section(symbols)
        symbols.map { |symbol| symbol(symbol) }.join(SYMBOL_DELIMITER)
      end

      def self.remained_section(count = 1)
        " ...残り#{count}件"
      end
    end
  end
end
