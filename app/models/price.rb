# frozen_string_literal: true

class Price
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :date
  attribute :open, :decimal
  attribute :high, :decimal
  attribute :low, :decimal
  attribute :close, :decimal
  attribute :adjusted_close, :decimal

  attribute :volume, :decimal
  attribute :unadjusted_volume, :decimal
  attribute :change, :decimal
  attribute :change_percent, :decimal
  attribute :vwap, :decimal # volume-weighted average price
  attribute :label, :string
  attribute :change_over_time, :decimal
  attribute :symbol, :string
end
