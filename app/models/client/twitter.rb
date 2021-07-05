# frozen_string_literal: true

module Client
  module Twitter
    API_HOST = "api.twitter.com"
    TWEET_END_POINT = "https://#{API_HOST}/1.1/statuses/update.json"

    CONSUMER_KEY = ENV["TWITTER_CONSUMER_KEY"]
    CONSUMER_SECRET = ENV["TWITTER_CONSUMER_SECRET"]
    ACCESS_TOKEN = ENV["TWITTER_ACCESS_TOKEN"]
    ACCESS_SECRET = ENV["TWITTER_ACCESS_SECRET"]

    def self.tweet(text)
      url = TWEET_END_POINT
      uri = URI.parse(url)

      consumer = OAuth::Consumer.new(
        CONSUMER_KEY,
        CONSUMER_SECRET,
        site: "https://#{API_HOST}/"
      )
      endpoint = OAuth::AccessToken.new(consumer, ACCESS_TOKEN, ACCESS_SECRET)

      endpoint.post(TWEET_END_POINT, status: text.to_s)
    end
  end
end
