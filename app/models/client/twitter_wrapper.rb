# frozen_string_literal: true

module Client
  module TwitterWrapper
    API_HOST = "api.twitter.com"
    TWEET_END_POINT = "https://#{API_HOST}/1.1/statuses/update.json"

    CONSUMER_KEY = ENV["TWITTER_CONSUMER_KEY"]
    CONSUMER_SECRET = ENV["TWITTER_CONSUMER_SECRET"]
    ACCESS_TOKEN = ENV["TWITTER_ACCESS_TOKEN"]
    ACCESS_SECRET = ENV["TWITTER_ACCESS_SECRET"]

    def self.new
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
        config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
        config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
        config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
      end
    end

    def self.tweet(text)
      client = new
      client.update(text)
    end
  end
end
