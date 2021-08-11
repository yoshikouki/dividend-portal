class AddCompanyIdToDividends < ActiveRecord::Migration[6.1]
  def change
    add_reference :dividends, :company, null: false, foreign_key: true
  end
end
