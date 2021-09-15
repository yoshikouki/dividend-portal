class CreatePrices < ActiveRecord::Migration[6.1]
  def change
    create_table :prices do |t|
      t.date :date
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.float :adjusted_close
      t.float :volume
      t.float :unadjusted_volume
      t.float :change
      t.float :change_percent
      t.float :vwap
      t.float :change_over_time
      t.string :symbol

      t.timestamps
    end
  end
end
