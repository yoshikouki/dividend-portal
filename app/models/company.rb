# frozen_string_literal: true

class Company < ApplicationRecord
  validates :symbol,
            presence: true
  validates :name,
            presence: true
  validates :exchange,
            presence: true

  def diff?(target, check_list)
    check_list.each do |c|
      return true unless self[c] == target[c]
    end
    false
  end
end
