class RenameSomeDateColumnsInDividend < ActiveRecord::Migration[6.1]
  def change
    rename_column :dividends, :ex_dividend_on, :ex_dividend_date
    rename_column :dividends, :records_on, :record_date
    rename_column :dividends, :pays_on, :payment_date
    rename_column :dividends, :declares_on, :declaration_date
    change_column :dividends, :ex_dividend_date, :date, null: false
    add_index :dividends, [:ex_dividend_date, :symbol], unique: true
  end
end
