# frozen_string_literal: true

class RenameRecentDividends < ActiveRecord::Migration[6.1]
  def change
    rename_table :recent_dividends, :dividends
  end
end
