class CreateMaintenanceDetails < ActiveRecord::Migration
  def change
    create_table :maintenance_details do |t|
      
      t.integer :maintenance_id 
      t.integer :component_id 
      
      
      t.text :diagnosis
      t.integer :diagnosis_case 
      
      t.text :solution 
      t.integer :solution_case  
      
      
      t.boolean :is_replacement_required, :default => false 
      t.integer :replacement_item_id  # if it happens to be replacement with another item. 

      t.timestamps
    end
  end
end
