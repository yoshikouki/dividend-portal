class ChangeCompanyIdOfDividendsToNullable < ActiveRecord::Migration[6.1]
  def change
    change_column :dividends, :company_id, :bigint, null: true
  end
end
