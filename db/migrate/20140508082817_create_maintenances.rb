class CreateMaintenances < ActiveRecord::Migration
  def change
    create_table :maintenances do |t|
      
      
      t.integer :asset_id  
      # t.integer :warehouse_id #which warehouse that solve this problem
      
      t.string :code
      
      t.datetime :complaint_date 
      t.text :complaint 
      t.integer :complaint_case # , :default => MAINTENANCE_CASE[:scheduled]  # or emergency
      
      
      
      t.boolean :is_confirmed, :default => false 
      t.datetime :confirmed_at
       
      
      t.boolean :is_deleted, :default => false 
      
      t.integer :warehouse_id 
      
      t.timestamps
    end
  end
end
