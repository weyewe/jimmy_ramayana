class CreateItemTypes < ActiveRecord::Migration
  def change
    create_table :item_types do |t|
      
      t.string :name 
      t.text :description 
      t.boolean :is_deleted, :default  => false

      t.timestamps
    end
  end
end
