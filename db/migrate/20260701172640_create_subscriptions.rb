class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.string  :publisher_class_name, null: false
      t.string  :listener_class_name,  null: false
      t.boolean :async,  null: false, default: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :subscriptions, [ :publisher_class_name, :listener_class_name ], unique: true, name: "index_subscriptions_on_publisher_and_listener"
    add_index :subscriptions, :active
  end
end
