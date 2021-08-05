# frozen_string_literal: true

class AddYearsOfDividendGrowthToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :years_of_dividend_growth, :integer
  end
end
