# frozen_string_literal: true

module ApplicationHelper
  def float_to_percentage(float, precision: 2)
    percentage = (BigDecimal(float, 10) * 100).to_f
    number_to_percentage(percentage, precision: 2)
  end
end
