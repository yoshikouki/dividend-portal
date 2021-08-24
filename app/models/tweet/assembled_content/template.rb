# frozen_string_literal: true

module Tweet
  class AssembledContent
    module Template
      SYMBOL_PREFIX = "$"
      SYMBOL_DELIMITER = " "

      def self.dividend_ex_dividend_previous_date(count = 0, date)
        AssembledContent.new(
          header: "【権利付き最終日通知 #{date.show}】",
          main: "本日までの購入で配当金が受け取れる #米国株 は#{count}件です",
        )
      end

      def self.dividend_latest_dividend(count = 0, date)
        AssembledContent.new(
          header: "【新着配当情報 #{date.show}】",
          main: "本日の新着 #配当 は #{count}件です",
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
