# frozen_string_literal: true

class CreateRecentDividends < ActiveRecord::Migration[6.1]
  def change
    create_table :recent_dividends do |t|
      t.date :ex_dividend_on
      t.date :records_on
      t.date :pays_on
      t.date :declares_on
      t.string :symbol
      t.decimal :dividend, precision: 30, scale: 25
      t.decimal :adjusted_dividend, precision: 30, scale: 25

      t.timestamps
    end

    add_index :recent_dividends, :symbol
  end
end
