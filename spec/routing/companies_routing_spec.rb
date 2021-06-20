# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompaniesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/companies").to route_to("companies#index")
    end

    it "routes to #show" do
      expect(get: "/companies/1").to route_to("companies#show", id: "1")
    end
  end
end
