class CreateStockAdjustmentDetails < ActiveRecord::Migration
  def change
    create_table :stock_adjustment_details do |t|
      t.integer :stock_adjustment_id 
      
      t.integer :item_id
      t.integer :quantity   
      t.boolean :is_confirmed, :default => false
      t.datetime :confirmed_at
      
      t.timestamps
    end
  end
end
