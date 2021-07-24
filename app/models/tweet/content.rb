# frozen_string_literal: true

module Tweet
  class Content
    attr_reader :dividends, :remained_dividends

    def initialize(dividends: [])
      @dividends = dividends
      @remained_dividends = dividends
    end

    def remained?
      !remained_dividends.nil? && remained_dividends.count.positive?
    end

    def ex_dividend_previous_date
      front_part = "今日までの購入で配当金が受け取れる米国株は「#{dividends.count}件」です (配当落ち前日)"
      if dividends.count.zero?
        front_part
      else
        <<~TWEET
          #{front_part}
          #{render_symbols_part(front_part, 240)}
        TWEET
      end
    end

    def latest_dividend
      front_part = "米国株に関する新着の配当金情報は #{dividends.count}件です"
      if dividends.count.zero?
        front_part
      else
        <<~TWEET
          #{front_part}
          #{render_symbols_part(front_part, 240)}
        TWEET
      end
    end

    def render_symbols_part(other_content = "", limited = 240)
      symbols = shift_symbols_in_number_of_characters(other_content, limited)
      symbols_part = symbols.map { |symbol| "$#{symbol}" }.join(" ")

      remaining_part = remained? ? " ...他#{remained_dividends.count}件" : ""

      "#{symbols_part}#{remaining_part}"
    end

    def remained_symbols
      render_symbols_part("", 240)
    end

    def shift_symbols_in_number_of_characters(other_content, limited)
      content_for_calculation = "#{other_content}\n"
      shift_number = 0
      remained_dividends.each.with_index(1) do |dividend, index|
        content_for_calculation += "$#{dividend.symbol} "
        next if content_weighted_length(content_for_calculation) > limited

        shift_number = index
      end
      remained_dividends.shift(shift_number).map(&:symbol)
    end

    # Twitter上の文字数を算出する
    def content_weighted_length(content)
      Twitter::TwitterText::Validation.parse_tweet(content)[:weighted_length]
    end
  end
end
