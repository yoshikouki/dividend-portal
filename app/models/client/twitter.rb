# frozen_string_literal: true

module Client
  class Twitter < ApplicationRecord
    API_HOST = "api.twitter.com"
    API_KEY = ENV["API_KEY_FMP"]
  end
end
