class AddIndexDateAndSymbolToPrices < ActiveRecord::Migration[6.1]
  def change
    add_index :prices, [:date, :symbol], unique: true
  end
end
