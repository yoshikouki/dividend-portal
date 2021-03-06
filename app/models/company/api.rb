# frozen_string_literal: true

class Company
  module Api
    PROFILE_CONVERSION = {
      symbol: :symbol,
      company_name: :name,
      currency: :currency,
      exchange: :exchange,
      exchange_short_name: :exchange_short_name,
      industry: :industry,
      sector: :sector,
      country: :country,
      image: :image,
      ipo_date: :ipo_date,
    }.freeze

    def self.fetch_all
      response = Fmp.symbols_list
      response.map do |r|
        r.delete(:price)
        r
      end
    end

    def self.profiles(*symbol)
      return [] unless symbol&.present?

      row_profiles = Fmp.profile(symbol)
      row_profiles.map do |raw_profile|
        convert_profile_response(raw_profile)
      end
    end

    def self.convert_profile_response(raw_profile)
      PROFILE_CONVERSION.map { |k, v| [v, raw_profile[k]] }.to_h
    end
  end
end
