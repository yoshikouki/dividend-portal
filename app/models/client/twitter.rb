# frozen_string_literal: true

module Client
  module Twitter
    API_HOST = "api.twitter.com"
    CONSUMER_KEY = ENV["TWITTER_CONSUMER_KEY"]
    CONSUMER_SECRET = ENV["TWITTER_CONSUMER_SECRET"]
    ACCESS_TOKEN = ENV["TWITTER_ACCESS_TOKEN"]
    ACCESS_SECRET = ENV["TWITTER_ACCESS_SECRET"]

    SIGNATURE_METHOD    = "HMAC-SHA1"
    OAUTH_VERSION       = "1.0"

    INITIAL_OAUTH_PARAMS = {
      oauth_consumer_key: CONSUMER_KEY,
      oauth_nonce: SecureRandom.uuid,
      oauth_signature_method: SIGNATURE_METHOD,
      oauth_timestamp: Time.zone.now.to_i,
      oauth_token: ACCESS_TOKEN,
      oauth_version: OAUTH_VERSION,
    }

    def self.tweet(text)
      url = "https://#{API_HOST}/1.1/statuses/update.json"
      uri = URI.parse(url)
      http_method = "POST"

      request = Net::HTTP::Post.new(uri)
      # request header 設定
      request.content_type = "application/json"
      request["Authorization"] = authorization_value_of_oauth(http_method, url)
      # request body 設定
      request.body = generate_request_body(text)

      options = {
        use_ssl: uri.scheme == "https",
      }

      Net::HTTP.start(uri.host, uri.port, options) do |http|
        http.request(request)
      end
    end

    def self.authorization_value_of_oauth(http_method, url)
      oauth_signature = generate_oauth_signature(http_method, url)
      params = oauth_params(oauth_signature)
      convert_to_authorization_value(params)
    end

    def self.generate_oauth_signature(http_method, url)
      before_encoding = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, signature_signing_key, signature_base_string(http_method, url))
      ERB::Util.url_encode(Base64.strict_encode64(before_encoding))
    end

    def self.signature_signing_key
      ERB::Util.url_encode("#{CONSUMER_SECRET}&#{ACCESS_SECRET}")
    end
    
    def self.signature_base_string(http_method, url)
      oauth_params_array = INITIAL_OAUTH_PARAMS.sort.map { |k, v| "#{k}=#{v}" }
      before_encoding = [http_method, url, *oauth_params_array].join("&")
      ERB::Util.url_encode(before_encoding)
    end

    def self.oauth_params(oauth_signature)
      INITIAL_OAUTH_PARAMS.merge ({
        oauth_signature: oauth_signature
      })
    end

    def self.convert_to_authorization_value(params)
      value = params.sort.map { |k, v| "#{k}=\"#{v}\"" }.join(",")
      "OAuth #{value}"
    end

    def self.generate_request_body(text)
      JSON.generate({
        status: text.to_s
      })
    end
  end
end
