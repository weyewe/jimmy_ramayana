class CreateWarehouseMutationDetails < ActiveRecord::Migration
  def change
    create_table :warehouse_mutation_details do |t|

      t.timestamps
    end
  end
end
