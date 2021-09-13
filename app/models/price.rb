# frozen_string_literal: true

class Price
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :date
  attribute :open, :float
  attribute :high, :float
  attribute :low, :float
  attribute :close, :float
  attribute :adjusted_close, :float

  attribute :volume, :float
  attribute :unadjusted_volume, :float
  attribute :change, :float
  attribute :change_percent, :float
  attribute :vwap, :float # volume-weighted average price
  attribute :label, :string
  attribute :change_over_time, :float
  attribute :symbol, :string

  def self.retrieve_by_api(from:, symbols: nil)
    Fmp::PriceList.historical(symbols, from: from)
                  .to_price_history
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
