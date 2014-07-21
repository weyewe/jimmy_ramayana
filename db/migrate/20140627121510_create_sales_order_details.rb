class CreateSalesOrderDetails < ActiveRecord::Migration
  def change
    create_table :sales_order_details do |t|
      t.integer :sales_order_id
      t.integer :item_id 
      
      t.decimal :discount, :default => 0, :precision => 5, :scale => 2  
      t.decimal :unit_price, :default => 0, :precision => 9, :scale => 2
      t.integer :quantity , :default => 0 
       
      t.integer :pending_delivery, :default => 0  
      
      t.boolean :is_confirmed, :default => false 
      t.datetime :confirmed_at
      
      t.timestamps
    end
  end
end
