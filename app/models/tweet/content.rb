module Tweet
  module Content
    def self.latest_dividend(dividends = [])
      front_part = "新着の配当金情報は#{dividends.count}件です"
      return front_part if dividends.count.zero?

      symbols_part = render_symbols_part(dividends, front_part, 240)

      <<~TWEET
      #{front_part}
      #{symbols_part}
      TWEET
    end

    def self.render_symbols_part(dividends = [], other_content = "", limited = 240)
      symbols = symbols_in_number_of_characters(dividends, other_content, 240)
      symbols_part = symbols.join(" ")

      remaining_count = dividends.count - symbols.count
      remaining_part += "...他#{remaining_count}件" if remaining_count.positive?

      "#{symbols_part} #{remaining_part}"
    end

    def self.symbols_in_number_of_characters(dividends, other_content, limited)
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
