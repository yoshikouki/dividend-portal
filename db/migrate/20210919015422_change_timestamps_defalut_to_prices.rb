class ChangeTimestampsDefalutToPrices < ActiveRecord::Migration[6.1]
  def change
    change_column :prices, :created_at, :datetime, precision: 6, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    change_column :prices, :updated_at, :datetime, precision: 6, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
