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
    from ||= Time.at(2.days.ago)
    dividends = Client::Fmp.get_dividend_calendar(
      from: from,
    )
    convert_calendar_for_visual(dividends)
  end

  def self.declared_on_today
    dividends = Client::Fmp.get_dividend_calendar(from: Time.at(1.month.ago))
    dividends.delete_if { |dividend| dividend[:declaration_date] != Time.now.strftime("%Y-%m-%d") }
    dividends.map { |dividend| new(dividend) }
  end

  private

    def self.convert_calendar_for_visual(dividends)
      dividends.map do |dividend|
        dividend.delete(:label)

        dividend.map do |key, value|
          [Client::Fmp::DIVIDEND_CALENDAR_CONVERSION[key], value]
        end.to_h
      end
    end
end
