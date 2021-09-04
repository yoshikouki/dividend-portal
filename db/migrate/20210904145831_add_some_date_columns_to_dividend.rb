class AddSomeDateColumnsToDividend < ActiveRecord::Migration[6.1]
  def change
    add_column :dividends, :ex_dividend_date, :date, null: false
    add_column :dividends, :record_date, :date
    add_column :dividends, :payment_date, :date
    add_column :dividends, :declaration_date, :date
    add_index :dividends, [:ex_dividend_date, :symbol], unique: true
  end
end
