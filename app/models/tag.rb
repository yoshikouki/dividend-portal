class Tag < ApplicationRecord
  has_many :company_tags
  has_many :companies, through: :company_tags
end
