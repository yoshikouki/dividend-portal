# frozen_string_literal: true

module Tweet
  def self.tweet(text)
    client = Client.new
    client.update(text)
  end

  def render_ex_dividend_previous_date(count = nil, symbols_text = nil)
    <<~TWEET
      今日までの購入で配当金が受け取れる米国株は「#{count}件」です (配当落ち前日)
      #{symbols_text}
    TWEET
  end
end
