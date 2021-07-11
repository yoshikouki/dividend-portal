# frozen_string_literal: true

class Workday < Date
  YEAR = 365 * 24 * 60 * 60
  HOLIDAYS_CACHE_END_DATE = Time.now + YEAR

  def holiday?(country = [])
    holiday(country).present?
  end

  def holiday(country = [])
    Holidays.on(self, country, :observed)
  end

  def workday?(country = :us)
    on_weekday? && !holiday?(country)
  end
end
