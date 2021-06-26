# frozen_string_literal: true

class Dividend
  attr_accessor :symbol,            # ティッカーシンボル
                :ex_dividend_date,  # 権利落ち日
                :record_date,       # 権利確定日
                :payment_date,      # 支払日
                :declaration_date,  # 発表日
                :dividend,          # 配当金
                :adjusted_dividend  # 調整後配当金

  def initialize(arg)
    @symbol = arg[:symbol]
    @ex_dividend_date = arg[:ex_dividend_date]
    @record_date = arg[:record_date]
    @payment_date = arg[:payment_date]
    @declaration_date = arg[:declaration_date]
    @dividend = arg[:dividend]
    @adjusted_dividend = arg[:adjusted_dividend]
  end

  def self.recent(from: nil, to: nil)
    Client::Fmp.get_dividend_calendar(
      from: from || Time.at(2.days.ago),
      to: to || Time.now,
    )
  end
end
