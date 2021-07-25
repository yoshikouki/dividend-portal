# frozen_string_literal: true

module Tweet
  class Content
    class Dividend
      attr_reader :dividends, :remained_dividends, :content

      def initialize(dividends: [], reference_date: Workday.today)
        @dividends = dividends
        @remained_dividends = dividends.clone
        @reference_date = reference_date
        @content = Content.new
      end

      def remained?
        !remained_dividends.nil? && remained_dividends.count.positive?
      end

      def ex_dividend_previous_date
        @content = Template.dividend_ex_dividend_previous_date(dividends.count, @reference_date)
        @content.footer_section = render_symbols_section if dividends.count.positive?
        @content.render
      end

      def latest_dividend
        @content = Template.dividend_latest_dividend(dividends.count, @reference_date)
        @content.footer_section = render_symbols_section if dividends.count.positive?
        @content.render
      end

      def remained_symbols
        render_symbols_section
      end

      def render_symbols_section(length = nil)
        length ||= calculate_symbols_section_length
        symbols = shift_symbols_in_number_of_characters(length)
        return "" unless symbols.present?

        symbols_section = Template.symbols_section(symbols)
        symbols_section += Template.remained_section(remained_dividends.count) if remained?
        symbols_section
      end

      def calculate_symbols_section_length
        max_remained_section_length = Content.weighted_length(Template.remained_section(dividends.count))
        Content::MAX_WEIGHTED_LENGTH - max_remained_section_length - @content.weighted_length
      end

      def shift_symbols_in_number_of_characters(limited)
        symbols_text_for_calculation = ""
        shift_number = 0
        remained_dividends.each.with_index(1) do |dividend, index|
          symbols_text_for_calculation += Template.symbol(dividend.symbol) + Template::SYMBOL_DELIMITER
          break if Content.weighted_length(symbols_text_for_calculation) > limited

          shift_number = index
        end
        remained_dividends.shift(shift_number).map(&:symbol)
      end
    end
  end
end
