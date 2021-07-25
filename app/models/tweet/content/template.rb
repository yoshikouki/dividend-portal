# frozen_string_literal: true

module Tweet
  class Content
    module Template
      SYMBOL_PREFIX = "$"
      SYMBOL_DELIMITER = " "

      def self.dividend_ex_dividend_previous_date(count = 0)
        Content.new(
          main: "今日までの購入で配当金が受け取れる米国株は「#{count}件」です (配当落ち前日)",
        )
      end

      def self.dividend_latest_dividend(count = 0)
        Content.new(
          main: "米国株に関する新着の配当金情報は #{count}件です",
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
