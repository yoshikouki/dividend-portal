# frozen_string_literal: true

Rails.application.routes.draw do
  get "dividend/index"
  get "dividend/recent"
  get "dividend/today"
  root "home#index"

  resources :companies
end
