class CreateAssetDetails < ActiveRecord::Migration
  def change
    create_table :asset_details do |t|
      t.integer :asset_id
      t.integer :component_id
      t.integer :current_item_id
      
      t.integer :initial_item_id  
      
      t.integer :maintenance_detail_id 
      
      
      t.timestamps
    end
  end
end
