# frozen_string_literal: true

class Company
  module Api
    def self.fetch_us
      response = Client::Fmp.get_symbols_list
      response.map do |r|
        r.delete(:price)
      end
    end
  end
end
