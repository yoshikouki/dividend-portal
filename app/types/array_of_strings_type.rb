# frozen_string_literal: true

class ArrayOfStringsType < ActiveModel::Type::Value
  def type
    :array_of_strings
  end
end
