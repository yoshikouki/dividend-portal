# frozen_string_literal: true

module Client
  module TwitterWrapper
    API_HOST = "api.twitter.com"
    API_KEY = ENV["API_KEY_FMP"]

    def self.new
      Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"],
        config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"],
        config.access_token        = ENV["TWITTER_ACCESS_TOKEN"],
        config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"],
      end
    end
  end
end
