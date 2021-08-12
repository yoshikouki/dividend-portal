class AddDisplayNameToTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :display_name, :string
    add_index :tags, :name, unique: true
  end
end
