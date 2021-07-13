# frozen_string_literal: true

class Dividend
  attr_accessor :symbol, # ティッカーシンボル
                :ex_dividend_on, # 権利落ち日
                :records_on, # 権利確定日
                :pays_on, # 支払日
                :declares_on, # 発表日
                :dividend, # 配当金
                :adjusted_dividend # 調整後配当金

  def initialize(arg)
    @symbol = arg[:symbol]
    @ex_dividend_on = arg[:ex_dividend_on]
    @records_on = arg[:records_on]
    @pays_on = arg[:pays_on]
    @declares_on = arg[:declares_on]
    @dividend = arg[:dividend]
    @adjusted_dividend = arg[:adjusted_dividend]
  end

  def self.recent(from: nil, to: nil)
    from ||= Time.at(2.days.ago)
    row_dividends = Client::Fmp.get_dividend_calendar(
      from: from,
      to: to,
    )
    to_instances(row_dividends)
  end

  def self.to_instances(row_dividends = [])
    row_dividends.map do |dividend|
      Dividend.new(
        ex_dividend_on: dividend[:date],
        records_on: dividend[:record_date],
        pays_on: dividend[:payment_date],
        declares_on: dividend[:declaration_date],
        symbol: dividend[:symbol],
        dividend: dividend[:dividend],
        adjusted_dividend: dividend[:adj_dividend],
      )
    end
  end

  def self.declared_from(time = Time.at(1.week.ago))
    # 念の為四半期のデータを持ってくる
    dividends = Client::Fmp.get_dividend_calendar(from: Time.at(3.months.ago))

    # 選択
    dividends = filter_by_condition(dividends, :declares_on, time)

    # View 用に変換
    dividends.map { |dividend| new(dividend) }
  end

  def self.filter_by_condition(dividends, condition, time)
    dividends.delete_if do |dividend|
      if dividend[condition].present?
        Time.parse(dividend[:declares_on]) < time
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

  def self.filter_by_ex_dividend_date(from_time = Time.now, _to_time = nil)
    return [] unless from_time.respond_to?(:strftime)

    from_date = from_time.strftime("%Y-%m-%d")
    to_date ||= from_date

    Client::Fmp.get_dividend_calendar(from: from_date, to: to_date)
  end
end
