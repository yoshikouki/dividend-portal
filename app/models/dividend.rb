# frozen_string_literal: true

class Dividend < ApplicationRecord
  belongs_to :company, optional: true

  has_many :report_queues, dependent: :destroy
  scope :not_notified, -> { where(notified: false) }
  scope :dividend_aristocrats, -> { includes(:company).joins(:company).merge(Company.dividend_aristocrats) }

  DEFAULT_INSERT_ALL = {
    ex_dividend_date: nil,
    record_date: nil,
    payment_date: nil,
    declaration_date: nil,
    symbol: nil,
    dividend: nil,
    adjusted_dividend: nil,
    company_id: nil,
    created_at: Time.current,
    updated_at: Time.current,
  }.freeze

  class << self
    def insert_all_with_api!(from: nil, latest_dividend_calendar: nil)
      latest_dividend_calendar ||= self::Api.recent(from: from)
      dividend_calendar_in_us = associate_with_us_companies(latest_dividend_calendar)
      attributes_array = convert_to_attributes_array(dividend_calendar_in_us)
      insert_all!(attributes_array.reverse) if attributes_array.present?
    end

    def insert_all_from_dividend_calendar!(dividend_calendar, associate_company: true)
      return unless dividend_calendar.present?

      dividend_calendar = associate_with_us_companies(dividend_calendar) if associate_company
      dividend_calendar = merge_timestamp(dividend_calendar)
      insert_all!(dividend_calendar)
    end

    private

    def associate_with_us_companies(dividend_calendar = [])
      symbols = dividend_calendar.pluck(:symbol)
      companies_in_us = Company.in_us_where_or_create_by_symbol(symbols).to_a
      symbols_in_us = companies_in_us.pluck(:symbol)

      dividend_calendar.filter_map do |dc|
        symbol = dc[:symbol]
        index = symbols_in_us.find_index(symbol)
        if index
          symbols_in_us.delete_at(index)
          company = companies_in_us.delete_at(index)
          dc.merge(company_id: company.id)
        end
      end
    end

    def convert_to_attributes_array(latest_dividend_calendar)
      current_dividends = order(:ex_dividend_date).to_a
      latest_dividend_calendar.filter_map do |latest|
        latest = remove_empty_string(latest)
        # dividends に保存されている配当の場合はスキップ
        current_index = current_dividends.find_index { |current| current.same?(latest) }
        if current_index
          current_dividends.delete_at(current_index) # 高速化のために削除しておく
          next
        end
        # companies に保存されていない企業の場合はスキップ
        unless latest[:company_id].present?
          latest[:company_id] = Company.find_by(symbol: latest[:symbol]) || next
        end

        merge_timestamp(latest)
      end
    end

    def remove_empty_string(hash)
      # #present? ではfalse(boolean)だった場合もnilにしてしまうため、シンプルに空文字を検証する
      hash.transform_values { |v| v == "" ? nil : v }
    end

    def merge_timestamp(dividend_calendar)
      case dividend_calendar
      when Array
        dividend_calendar.map { |dividend| DEFAULT_INSERT_ALL.deep_dup.merge(dividend) }
      when Hash
        DEFAULT_INSERT_ALL.deep_dup.merge(dividend_calendar)
      end
    end
  end

  def same?(attributes)
    ex_dividend_date == Date.parse(attributes[:ex_dividend_date]) &&
      symbol == attributes[:symbol]
  end
end
