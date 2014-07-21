class AddTypeToItem < ActiveRecord::Migration
  def change
    add_column :items,  :item_type_id, :integer
  end
end
