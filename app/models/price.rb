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
end
