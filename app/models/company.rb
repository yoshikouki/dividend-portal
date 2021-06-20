# frozen_string_literal: true

class Company < ApplicationRecord
  def self.all
    Client::Fmp.get_symbols_list
  end
end
