# frozen_string_literal: true

class AddProfileColumnsToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :industry, :string
    add_column :companies, :sector, :string
    add_column :companies, :country, :string
    add_column :companies, :currency, :string
    add_column :companies, :exchange_short_name, :string, after: :exchange
    add_column :companies, :ipo_date, :date
    add_column :companies, :image, :string

    add_index :companies, :symbol
  end
end
