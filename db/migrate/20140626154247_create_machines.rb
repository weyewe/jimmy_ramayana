class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :name 
      t.string :brand
      t.text :description 

      t.timestamps
    end
  end
end
