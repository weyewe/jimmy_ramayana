class WarehouseItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :warehouse 
  
  validates_presence_of :item_id, :warehouse_id 
  
  validate :valid_item_id
  validate :valid_warehouse_id 
  
  def valid_item_id
    return if not item_id.present? 
    selected_item = Item.find_by_id item_id
    if selected_item.nil?
      self.errors.add(:item_id, "Harus dipilih")
      return self 
    end
  end
  
  def valid_warehouse_id
    return if not warehouse_id.present? 
    selected_warehouse = Warehouse.find_by_id warehouse_id
    
    if selected_warehouse.nil?
      self.errors.add(:warehouse_id, "Harus dipilih")
      return self 
    end
  end
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.item_id    =  params[:item_id]
    new_object.warehouse_id  = params[:warehouse_id]
    
    new_object.save
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    self.item_id    =   params[:item_id]
    self.warehouse_id  = params[:warehouse_id]
    
    self.save
    
    return self
  end
  
  def delete_object
    
    self.errors.add(:generic_errors, "Tidak bisa dihapus")
    return self 
  end 
  
  
  def self.active_objects
    self 
  end
  
  def update_stock_mutation( stock_mutation ) 
    return if not stock_mutation.item_case == STOCK_MUTATION_ITEM_CASE[:ready]
    
    
    multiplier = 1
    if stock_mutation.case == STOCK_MUTATION_CASE[:deduction]
      multiplier = -1 
    end
    
    self.ready += multiplier * stock_mutation.quantity 
    self.save 
  end
  
  def reverse_stock_mutation(stock_mutation)
    return if not stock_mutation.item_case == STOCK_MUTATION_ITEM_CASE[:ready]
    
    multiplier = 1
    if stock_mutation.case == STOCK_MUTATION_CASE[:addition]
      multiplier = -1 
    end
    
    self.ready += multiplier * stock_mutation.quantity 
    self.save 
  end
  
  
end
