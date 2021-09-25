# frozen_string_literal: true

class Price < ApplicationRecord
  validates :date, uniqueness: { scope: :symbol }, presence: true

  scope :on_calendar_week, ->(date = Date.current) { where(date: date.at_beginning_of_week..date.at_end_of_week) }

  def self.where_from_api(symbol:, date: nil)
    fpl = Fmp::PriceList.historical(symbol, date: date)
    attributes = fpl.to_prices_attributes
    attributes.map { |attr| new(attr) }
  end

  def for_the_week_of?(arg)
    reference_date = to_date(arg)
    date.between? reference_date.at_beginning_of_week, reference_date.at_end_of_week
  end

  private

  def to_date(arg)
    arg.is_a?(DateAndTime) ? arg : Date.parse(arg)
  end
end
