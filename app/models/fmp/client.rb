# frozen_string_literal: true

module Fmp
  module Client
    API_HOST = "financialmodelingprep.com"
    API_KEY = Rails.application.credentials.fmp[:api_key]

    class << self
      def get(path, query_hash = {})
        url = Converter.url(path, query_hash)
        uri = URI.parse(url)
        req = Net::HTTP::Get.new(uri)
        req["Upgrade-Insecure-Requests"] = "1"
        options = {
          use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.host, uri.port, options) do |http|
          http.request(req)
        end
        Converter.parse_response_body(response)
      end
    end
  end
end
