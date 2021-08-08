class ChangeAdjustedDividendToFloat < ActiveRecord::Migration[6.1]
  def change
    change_column :dividends, :dividend, :float
    change_column :dividends, :adjusted_dividend, :float
  end
end
