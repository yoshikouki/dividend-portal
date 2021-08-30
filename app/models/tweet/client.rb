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
    }.freeze

    CREDENTIALS_FOR_DEV = {
      consumer_key: "8wwEvpXmANbgYro5FMdCrWVwy",
      consumer_secret: Rails.application.credentials.twitter[:consumer_secret_for_dev],
      access_token: "1167600595739365376-5B0zppIhWBxZ66S4hLAOxRlDOJMh0H",
      access_token_secret: Rails.application.credentials.twitter[:access_secret_for_dev],
    }.freeze

    class << self
      # reply_to: Twitter::Tweet
      def tweet(text, reply_to: nil, dev: false)
        option = reply_to ? { in_reply_to_status: reply_to } : {}
        client(dev: dev).update(text, option)
      end

      def tweet_with_image(text, image, dev: false)
        raise "Invalid image" unless image && image != File

        client(dev: dev).update_with_media(text, image)
      end

      private

      def client(dev: false)
        credentials = dev ? CREDENTIALS_FOR_DEV : CREDENTIALS
        Twitter::REST::Client.new(credentials)
      end
    end
  end
end
