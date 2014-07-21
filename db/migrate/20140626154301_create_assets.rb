class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.integer :machine_id 
      t.integer :contact_id 
      t.string :code
      t.text :description 
      
      t.boolean :is_deleted, :default => false 
      

      t.timestamps
    end
  end
end
