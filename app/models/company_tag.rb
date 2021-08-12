# frozen_string_literal: true

class CompanyTag < ApplicationRecord
  belongs_to :company
  belongs_to :tag

  validates :company_id, uniqueness: { scope: :tag_id }
end
