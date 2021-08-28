# frozen_string_literal: true

module Tweet
  module Client
    API_HOST = "api.twitter.com"
    TWEET_END_POINT = "https://#{API_HOST}/1.1/statuses/update.json"

    CREDENTIALS = {
      consumer_key: "8YdmRHRF40jw6kzstjJAg5gzH",
      consumer_secret: Rails.application.credentials.twitter[:consumer_secret],
      access_token: "1409097772528148482-JvlKIcCm7g7SXLg1ILHZDi0OM1EnfG",
      access_token_secret: Rails.application.credentials.twitter[:access_secret],
    }

    CREDENTIALS_FOR_DEV = {
      consumer_key: "8wwEvpXmANbgYro5FMdCrWVwy",
      consumer_secret: Rails.application.credentials.twitter[:consumer_secret_for_dev],
      access_token: "1167600595739365376-5B0zppIhWBxZ66S4hLAOxRlDOJMh0H",
      access_token_secret: Rails.application.credentials.twitter[:access_secret_for_dev],
    }

    def self.new(dev: false)
      credentials = dev ? CREDENTIALS_FOR_DEV : CREDENTIALS
      Twitter::REST::Client.new(credentials)
    end
  end
end
