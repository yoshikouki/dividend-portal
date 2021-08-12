class Tag < ApplicationRecord
  has_many :company_tags
  has_many :companies, through: :company_tags

  REGEXP_NAME = /\A[a-zA-Z]\w*[a-zA-Z]\z/i

  validates :name,
            presence: true,
            uniqueness: true,
            length: { minimum: 2 },
            format: { with: REGEXP_NAME }

  validates :display_name,
            presence: true,
            uniqueness: true
end
