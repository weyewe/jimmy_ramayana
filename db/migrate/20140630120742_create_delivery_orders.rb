class CreateDeliveryOrders < ActiveRecord::Migration
  def change
    create_table :delivery_orders do |t|
      t.integer :sales_order_id 
      t.text :description 
      t.datetime :delivery_date  
      
      t.boolean :is_confirmed , :default => false
      t.datetime :confirmed_at 
      
      t.boolean :is_deleted , :default => false
      
      t.integer :warehouse_id 
      
      
      t.timestamps
    end
  end
end
