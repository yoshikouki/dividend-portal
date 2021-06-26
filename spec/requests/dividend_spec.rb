# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dividends", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/dividend/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /recent" do
    it "returns http success" do
      get "/dividend/recent"
      expect(response).to have_http_status(:success)
    end
  end
end
