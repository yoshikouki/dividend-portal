# frozen_string_literal: true

module ApplicationHelper
  def float_to_percentage(float, precision: 2)
    percentage = (BigDecimal(float, 10) * 100).to_f
    number_to_percentage(percentage, precision: precision)
  end

  def dollar_display_with_increase_or_decrease(int)
    sign = if int.positive?
      "+"
    elsif int.negative?
      "-"
    end
    "#{sign}$#{int}"
  end
end
