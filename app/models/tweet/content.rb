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
      content_for_calculation = template_for_ex_dividend_previous_date(dividends.count)
      tweet_symbols = []

      dividends.each do |dividend|
        content_for_calculation += "$#{dividend[:symbol]} "
        break if Twitter::TwitterText::Validation.parse_tweet(content_for_calculation)[:weighted_length] > 240

        tweet_symbols << dividend[:symbol]
      end
      remaining_count = dividends.count - tweet_symbols.count
      template_for_ex_dividend_previous_date(dividends.count, tweet_symbols, remaining_count)
    end

    def template_for_ex_dividend_previous_date(dividends_count = 0, tweet_symbols = [], remaining_count = 0)
      front_part = "今日までの購入で配当金が受け取れる米国株は「#{dividends_count}件」です (配当落ち前日)"
      return front_part if dividends_count.zero?

      symbols_part = tweet_symbols.map { |s| "$#{s}" }.join(" ")
      symbols_part += "...他#{remaining_count}件" if remaining_count.positive?

      <<~TWEET
        #{front_part}
        #{symbols_part}
      TWEET
    end

    def latest_dividend
      front_part = "米国株に関する新着の配当金情報は #{dividends.count}件です"
      return front_part if dividends.count.zero?

      symbols_part = render_symbols_part(dividends, front_part, 240)

      <<~TWEET
        #{front_part}
        #{symbols_part}
      TWEET
    end

    def render_symbols_part(other_content = "", _limited = 240)
      symbols = symbols_in_number_of_characters(dividends, other_content, 240)
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
