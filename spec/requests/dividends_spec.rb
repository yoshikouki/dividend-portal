# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dividends", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/dividends/"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /recent" do
    it "returns http success" do
      get "/dividends/recent"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /declaration" do
    it "returns http success" do
      get "/dividends/declaration"
      expect(response).to have_http_status(:success)
    end
  end
end
