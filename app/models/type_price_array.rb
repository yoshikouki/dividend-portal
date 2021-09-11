# frozen_string_literal: true

class TypePriceArray < ActiveModel::Type::Value
  private

  def cast_value(value)
    raise TypePriceArrayArgumentError unless value.is_a?(Array)

    array = case value.first
            when Hash
              value.map { |arg| Price.new(arg) }
            when Price
              value
            else
              raise TypePriceArrayArgumentError
    end

    super(array)
  end

  class TypePriceArrayArgumentError < ArgumentError; end
end
