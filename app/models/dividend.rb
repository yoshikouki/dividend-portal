# frozen_string_literal: true

class Dividend < ApplicationRecord
  scope :not_notified, -> { where(notified: false) }

  def self.declared_from(time = Time.at(1.week.ago))
    # TODO: ActiveRecord を継承していい感じに処理を改める。このままではWebアプリの方は動かない
    # 期間は念の為四半期分
    row_dividends = Client::Fmp.get_dividend_calendar(from: Time.at(3.months.ago))

    # 選択
    dividends = filter_by_condition(convert_response_of_dividend_calendar(row_dividends), :declares_on, time)

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
end
