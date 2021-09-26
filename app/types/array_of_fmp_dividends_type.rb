# frozen_string_literal: true

class ArrayOfFmpDividendsType < ActiveModel::Type::Value
  private

  def cast_value(value)
    raise ArgumentError unless value.is_a?(Array)

    array = case value.first
            when Hash
              value.map { |arg| Fmp::Dividend.new(arg) }
            when Fmp::Dividend
              value
            else
              []
    end
    super(array)
  end
end
