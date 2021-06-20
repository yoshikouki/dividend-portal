# frozen_string_literal: true

class Company < ApplicationRecord
  validates :symbol,
           presence: true
  validates :name,
           presence: true
  validates :exchange,
           presence: true

  def self.all
    Client::Fmp.get_symbols_list
  end
end
