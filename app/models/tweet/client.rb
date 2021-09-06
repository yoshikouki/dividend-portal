# frozen_string_literal: true

class Tweet
  class Client
    attr_accessor :client

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
      def tweet(text, reply_to: nil, env: :production)
        client(env).tweet(text, reply_to: reply_to)
      end

      def tweet_with_image(text, image, env: :production)
        client(env).tweet_with_image(text, image)
      end

      private

      def client(env = :production)
        new(env)
      end
    end

    def initialize(env = :production)
      credentials = env == :production ? CREDENTIALS : CREDENTIALS_FOR_DEV
      @client = Twitter::REST::Client.new(credentials)
    end

    # reply_to: Twitter::Tweet
    def tweet(text, reply_to: nil)
      option = reply_to ? { in_reply_to_status: reply_to } : {}
      client.update(text, option)
    end

    def tweet_with_image(text, image)
      raise "Invalid image" unless image && image != File

      client.update_with_media(text, image)
    end
  end
end
