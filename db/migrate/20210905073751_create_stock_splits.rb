class CreateStockSplits < ActiveRecord::Migration[6.1]
  def change
    create_table :stock_splits do |t|
      t.date :date
      t.string :symbol
      t.float :numerator
      t.float :denominator

      t.timestamps
    end
    add_index :stock_splits, [:date, :symbol], unique: true
  end
end
