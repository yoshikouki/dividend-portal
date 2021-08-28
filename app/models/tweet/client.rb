# frozen_string_literal: true

module Tweet
  module Client
    API_HOST = "api.twitter.com"
    TWEET_END_POINT = "https://#{API_HOST}/1.1/statuses/update.json"

    CONSUMER_KEY = "8YdmRHRF40jw6kzstjJAg5gzH"
    CONSUMER_SECRET = Rails.application.credentials.twitter[:consumer_secret]
    ACCESS_TOKEN = "1409097772528148482-JvlKIcCm7g7SXLg1ILHZDi0OM1EnfG"
    ACCESS_SECRET = Rails.application.credentials.twitter[:access_secret]

    def self.new
      Twitter::REST::Client.new do |config|
        config.consumer_key        = CONSUMER_KEY
        config.consumer_secret     = CONSUMER_SECRET
        config.access_token        = ACCESS_TOKEN
        config.access_token_secret = ACCESS_SECRET
      end
    end
  end
end
