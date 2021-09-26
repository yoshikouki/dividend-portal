# frozen_string_literal: true

class ArrayOfIntegersType < ActiveModel::Type::Value
  def type
    :array_of_integers
  end

  def cast(values)
    return if values.blank?

    values.map(&:to_i)
  end
end
