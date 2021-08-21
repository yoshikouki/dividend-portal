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

  def self.transform_keys_to_snake_case_and_symbol(body)
    # TODO: 孫子要素が[{}]の階層を持っていると変換されないので、必要になったら修正する
    case body
    when Array
      body.map do |item, value|
        case value
        when Array, Hash
          transform_keys_to_snake_case_and_symbol(value)
        else
          item.transform_keys { |key| key.underscore.to_sym }
        end
      end
    when Hash
      transformed_hash = body.map do |key, value|
        case value
        when Array, Hash
          value = transform_keys_to_snake_case_and_symbol(value)
        end
        [key.underscore.to_sym, value]
      end
      transformed_hash.to_h
    end
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
