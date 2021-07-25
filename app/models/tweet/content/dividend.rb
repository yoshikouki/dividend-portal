# frozen_string_literal: true

module Tweet
  class Content
    class Dividend
      attr_reader :dividends, :remained_dividends

      def initialize(dividends: [])
        @dividends = dividends
        @remained_dividends = dividends
        @content = Content.new
      end

      def remained?
        !remained_dividends.nil? && remained_dividends.count.positive?
      end

      def ex_dividend_previous_date
        @content.main_section = "今日までの購入で配当金が受け取れる米国株は「#{dividends.count}件」です (配当落ち前日)"
        @content.footer_section = render_symbols_part if dividends.count.positive?
        @content.render
      end

      def latest_dividend
        @content.main_section = "米国株に関する新着の配当金情報は #{dividends.count}件です"
        @content.footer_section = render_symbols_part if dividends.count.positive?
        @content.render
      end

      def remained_symbols
        render_symbols_part
      end

      def render_symbols_part(length = nil)
        length ||= calculate_symbols_part_length
        symbols = shift_symbols_in_number_of_characters(length)

        symbols_part = symbols.map { |symbol| "$#{symbol}" }.join(" ")
        symbols_part += " ...残り#{remained_dividends.count}件" if remained?
        symbols_part
      end

      def calculate_symbols_part_length
        max_remained_part_length = Content.weighted_length(" ...残り#{dividends.count}件")
        Content::MAX_WEIGHTED_LENGTH - max_remained_part_length - @content.weighted_length
      end

      def shift_symbols_in_number_of_characters(limited)
        symbols_text_for_calculation = ""
        shift_number = 0
        remained_dividends.each.with_index(1) do |dividend, index|
          symbols_text_for_calculation += "$#{dividend.symbol} "
          break if Content.weighted_length(symbols_text_for_calculation) > limited

          shift_number = index
        end
        remained_dividends.shift(shift_number).map(&:symbol)
      end
    end
  end
end
