# frozen_string_literal: true

class Price
  class History
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :prices, :price_array, default: []
  end
end
