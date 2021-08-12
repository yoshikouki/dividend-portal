class CreateCompanyTags < ActiveRecord::Migration[6.1]
  def change
    create_table :company_tags do |t|
      t.references :company, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
