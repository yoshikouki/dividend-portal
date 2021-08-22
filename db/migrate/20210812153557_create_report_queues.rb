class CreateReportQueues < ActiveRecord::Migration[6.1]
  def change
    create_table :report_queues do |t|
      t.string :type
      t.references :dividend, null: false, foreign_key: true

      t.timestamps
    end
  end
end
