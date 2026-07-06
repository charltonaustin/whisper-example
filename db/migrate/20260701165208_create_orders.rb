class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :customer_name
      t.integer :total_cents

      t.timestamps
    end
  end
end
