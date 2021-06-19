# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :companies do |t|
      t.string :symbol
      t.string :name
      t.string :exchange

      t.timestamps
    end
  end
end
