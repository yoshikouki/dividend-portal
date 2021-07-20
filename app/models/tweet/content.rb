module Tweet
  module Content
    def self.latest_dividend(dividends = [])

    end

    def self.symbols_in_number_of_characters(dividends = [], other_content = "", limited = 240)
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
