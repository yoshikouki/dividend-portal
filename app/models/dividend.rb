# frozen_string_literal: true

class Dividend < ApplicationRecord
  belongs_to :company

  has_many :report_queues, dependent: :destroy
  scope :not_notified, -> { where(notified: false) }
  scope :dividend_aristocrats, -> { includes(:company).joins(:company).merge(Company.dividend_aristocrats) }

  DEFAULT_INSERT_ALL = {
    ex_dividend_on: nil,
    records_on: nil,
    pays_on: nil,
    declares_on: nil,
    symbol: nil,
    dividend: nil,
    adjusted_dividend: nil,
    company_id: nil,
    created_at: Time.current,
    updated_at: Time.current,
  }

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
        Client::Fmp::Converter::DIVIDEND_CALENDAR_FOR_VIEW[key]
      end
    end
  end

  def same?(attributes)
    ex_dividend_on == Date.parse(attributes[:ex_dividend_on]) &&
      symbol == attributes[:symbol]
  end

  def updated?(attributes)
    attributes.each do |k, v|
      source = self[k]
      case source
      when Date
        return true if source != Date.parse(v)
      else
        return true if source != v
      end
    end
    false
  end
end
