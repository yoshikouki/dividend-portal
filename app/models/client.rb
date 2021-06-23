# frozen_string_literal: true

module Client
  def self.get(url)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri)
    req["Upgrade-Insecure-Requests"] = "1"
    options = {
      use_ssl: uri.scheme == "https",
    }

    res = Net::HTTP.start(uri.host, uri.port, options) do |http|
      http.request(req)
    end

    parse_response_body res
  end

  def self.parse_response_body(response)
    body = response.body
    body = JSON.parse body if response["content-type"].include?("application/json")
    body
  end

  def self.value_to_time(hash)
    hash.each do |key, value|
      next if value.instance_of? Time

      hash[key] = Time.parse(value).strftime("%Y-%m-%d")
    end
  end
end
