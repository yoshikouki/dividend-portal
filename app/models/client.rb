# frozen_string_literal: true

module Client
  def self.get(url)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri)
    req["Upgrade-Insecure-Requests"] = "1"
    options = {
      use_ssl: uri.scheme == "https",
    }

    Net::HTTP.start(uri.host, uri.port, options) do |http|
      http.request(req)
    end
  end

  def self.parse_response_body(body:, content_type: nil)
    if content_type&.include?("application/json")
      body = JSON.parse(body)
      body = body.map { |item| item.transform_keys { |key| key.underscore.to_sym }.to_h }
    end
    body
  end

  def self.value_to_time(hash)
    hash.each do |key, value|
      hash[key] = if value.instance_of? Time
        value.strftime("%Y-%m-%d")
      else
        Time.parse(value).strftime("%Y-%m-%d")
      end
    end
  end
end
