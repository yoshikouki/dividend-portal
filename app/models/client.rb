# frozen_string_literal: true

class Client < ApplicationRecord
  def self.get(url)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri)
    req["Upgrade-Insecure-Requests"] = "1"
    options = {
      use_ssl: uri.scheme == "https",
    }

    res = Net::HTTP.start(uri.host, uri.port, options) {|http|
      http.request(req)
    }

    if res["content-type"].include?("application/json")
      JSON.parse res.body
    else
      res.body
    end
  end
end
