# frozen_string_literal: true

class ReportQueue < ApplicationRecord
  belongs_to :dividend

  class << self
    def dequeue
      return unless dequeue_target

      dequeue_target.destroy
    end

    def dequeue_target
      first
    end
  end
end
