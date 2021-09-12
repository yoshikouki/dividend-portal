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

  def self.retrieve_by_api(symbols: nil, from:)
    [
      Price.new(
        date: "2021-09-01",
        open: 56.38,
        high: 56.8,
        low: 56.28,
        close: 56.69,
        volume: 9404637.0,
        change: 0.31,
        change_percent: 0.55,
        symbol: symbols,
      ),
    ]
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
