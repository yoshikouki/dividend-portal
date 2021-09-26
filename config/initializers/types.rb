# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  ActiveModel::Type.register(:price_array, TypePriceArray)
  ActiveModel::Type.register(:array_of_fmp_dividends, ArrayOfFmpDividendsType)
  ActiveModel::Type.register(:array_of_strings, ArrayOfStringsType)
end
