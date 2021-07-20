# frozen_string_literal: true

class AddNotifiedToDividend < ActiveRecord::Migration[6.1]
  def change
    add_column :dividends, :notified, :boolean, default: false
  end
end
