# frozen_string_literal: true

class ReportQueue < ApplicationRecord
  belongs_to :dividend

  class << self
    def enqueue(dividend: nil)
    end

    def dequeue
    end
  end
end
