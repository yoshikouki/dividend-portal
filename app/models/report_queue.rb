# frozen_string_literal: true

class ReportQueue < ApplicationRecord
  belongs_to :dividend

  class << self
    def dequeue
    end
  end
end
