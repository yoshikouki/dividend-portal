# frozen_string_literal: true

Rails.application.routes.draw do
  get "/dividends", to: "dividends#index"
  get "/dividends/recent"
  get "/dividends/today"
  root "home#index"

  resources :companies
end
