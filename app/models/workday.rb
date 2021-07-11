# frozen_string_literal: true

class Workday < Date
  def holiday?(country = [])
    holiday(country).present?
  end

  def holiday(country = [])
    Holidays.on(self, country)
  end
end
