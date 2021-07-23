# frozen_string_literal: true

module Tweet
  class Content
    attr_reader :dividends, :remained_dividends

    def initialize(dividends: [])
      @dividends = dividends
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

    def render_symbols_part(other_content = "", _limited = 240)
      symbols = symbols_in_number_of_characters(other_content, 240)
      symbols_part = symbols.join(" ")

      remaining_count = dividends.count - symbols.count
      remaining_part = remaining_count.positive? ? " ...他#{remaining_count}件" : ""

      "#{symbols_part}#{remaining_part}"
    end

    def remained_symbols
      #  WIP
    end

    def symbols_in_number_of_characters(other_content, limited)
      content_for_calculation = "#{other_content}\n"
      symbols = dividends.map do |dividend|
        symbol = "$#{dividend.symbol}"
        content_for_calculation += "#{symbol} "
        next if Twitter::TwitterText::Validation.parse_tweet(content_for_calculation)[:weighted_length] > limited

        symbol
      end
      symbols.compact
    end
  end
end
