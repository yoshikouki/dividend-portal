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
      to: to,
    )
    convert_calendar_for_visual(dividends)
  end

  def self.declared_from(time = Time.at(1.week.ago))
    # 念の為四半期のデータを持ってくる
    dividends = Client::Fmp.get_dividend_calendar(from: Time.at(3.months.ago))

    # 選択
    dividends = filter_by_condition(dividends, :declaration_date, time)

    # View 用に変換
    dividends.map { |dividend| new(dividend) }
  end

  def self.filter_by_condition(dividends, condition, time)
    dividends.delete_if do |dividend|
      if dividend[condition].present?
        Time.parse(dividend[:declaration_date]) < time
      else
        true
      end
    end
    dividends
  end

  def self.convert_calendar_for_visual(dividends)
    dividends.map do |dividend|
      dividend.delete(:label)

      dividend.transform_keys do |key|
        Client::Fmp::DIVIDEND_CALENDAR_CONVERSION[key]
      end
    end
  end

  def self.filter_by_ex_dividend_date(from_time = Time.now, to_time = nil)
    return [] unless from_time.instance_of?(Time)

    from_date = time.strftime("%Y-%m-%d")
    to_date ||= from_date

    Client::Fmp.get_dividend_calendar(from: from_date, to: to_date)
  end
end
