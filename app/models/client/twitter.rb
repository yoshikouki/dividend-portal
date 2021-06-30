# frozen_string_literal: true

module Client
  module Twitter
    API_HOST = "api.twitter.com"
    TWITTER_CONSUMER_KEY = ENV["TWITTER_CONSUMER_KEY"]
    TWITTER_CONSUMER_SECRET = ENV["TWITTER_CONSUMER_SECRET"]
    TWITTER_ACCESS_TOKEN = ENV["TWITTER_ACCESS_TOKEN"]
    TWITTER_ACCESS_SECRET = ENV["TWITTER_ACCESS_SECRET"]

    def self.tweet(text)
    end
  end
end
