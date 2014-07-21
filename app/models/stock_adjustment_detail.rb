class StockAdjustmentDetail < ActiveRecord::Base
  belongs_to :stock_adjustment
  belongs_to :item 
  
  validates_presence_of :quantity, :item_id, :stock_adjustment_id 
  
  validate :non_zero_quantity
  validate :non_negative_final_quantity
  validate :non_negative_final_quantity_in_warehouse 
  
  validate :valid_item_id
  validate :unique_item_in_stock_adjustment_detail
  validate :can_not_create_if_parent_is_confirmed
  
  
  def can_not_create_if_parent_is_confirmed
    return if not self.stock_adjustment_id.present?
    return if self.persisted?
    
    if stock_adjustment.is_confirmed?
      self.errors.add(:generic_errors, "Stock Adjustment sudah konfirmasi")
      return self 
    end
  end
  
  
  
  def valid_item_id
    return  if not item_id.present? 
    object = Item.find_by_id item_id
    
    if object.nil?
      self.errors.add(:item_id, "Harus ada dan valid")
      return self 
    end
  end
  
  def warehouse_item
    return if not stock_adjustment_id.present? 
    return if not item_id.present? 
    
    selected_warehouse_item = WarehouseItem.where(
      :item_id => item_id,
      :warehouse_id => self.stock_adjustment.warehouse_id
    ).first 
    
    if selected_warehouse_item.nil?
      return WarehouseItem.create_object(
        :item_id => item_id,
        :warehouse_id =>  self.stock_adjustment.warehouse_id
      )
    else
      return selected_warehouse_item
    end
    
  end
  
  
  def non_zero_quantity
    return if not quantity.present? 
    if quantity == 0 
      self.errors.add(:quantity, "Tidak boleh 0 ")
      return self 
    end
  end
  
  def non_negative_final_quantity
    return if not item.present? 
    return if not quantity.present?
    
    initial_quantity = item.ready
    additional_quantity = quantity
    final_quantity = additional_quantity + initial_quantity
    
    if final_quantity  < 0 
      self.errors.add(:quantity, "Jumlah akhir tidak boleh negative")
      return self 
    end
     
  end
  
  def non_negative_final_quantity_in_warehouse
    return if not stock_adjustment_id.present? 
    return if not item_id.present?
    return if not quantity.present?
    
    if quantity < 0 
      if warehouse_item.ready  + quantity < 0 
        self.errors.add(:quantity, "Tidak ada cukup kuantitas di gudang")
        return self 
      end
    end
    
  end
  
  def unique_item_in_stock_adjustment_detail
    return if not ( item_id.present? ) 
    
    object_count  = StockAdjustmentDetail.where(
      :item_id => item_id,
      :stock_adjustment_id => stock_adjustment_id
    ).count 
    
    object = StockAdjustmentDetail.where(
      :item_id => item_id,
      :stock_adjustment_id => stock_adjustment_id
    ).first
    
    if self.persisted? and object.id != self.id   and object_count == 1
      self.errors.add(:item_id, "Sudah ada Item seperti ini")
      return self 
    end
    
    # there is item with such item_id in the database
    if not self.persisted? and object_count != 0 
      self.errors.add(:item_id, "Sudah ada Item seperti ini")
      return self
    end
  end
   
  
  def self.create_object( params ) 
    
      
    
    new_object = self.new
    new_object.stock_adjustment_id = params[:stock_adjustment_id ]
    new_object.item_id = params[:item_id]
    new_object.quantity = params[:quantity]
    
    
    new_object.save 
    
    return new_object
  end
  
  
  def update_object(params)
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Tidak bisa update")
      return self 
    end
     
    self.item_id = params[:item_id]
    self.quantity = params[:quantity]
    self.save
  end
   
  
  
  
  def delete_object
    if not self.stock_adjustment.is_confirmed?
      self.destroy 
    else
      self.errors.add(:generic_errors, "Sudah konfirmasi. Tidak bisa delete")
      return self 
    end
  end
  
  
  
  def confirmable? 
    return false if self.stock_adjustment.is_confirmed?
    
    self.non_negative_final_quantity
    self.non_negative_final_quantity_in_warehouse
    return false if self.errors.size != 0  
    
    
    return true
  end
  
   
  
  def confirm_object(confirmation_datetime)
    return self if not self.confirmable?
    
    stock_mutation_case  = STOCK_MUTATION_CASE[:addition]
    stock_mutation_case  = STOCK_MUTATION_CASE[:deduction] if quantity < 0 
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      stock_mutation_case, # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:ready]  , # stock_mutation_item_case
      stock_adjustment.warehouse_id 
     )
     
  
    item.update_stock_mutation( stock_mutation ) 
    warehouse_item.update_stock_mutation(stock_mutation) 
    
    self.is_confirmed = true
    self.save
    
     
  end
  
  def unconfirmable?
    return false if not self.is_confirmed? 
    
    final_quantity = item.ready + -1*self.quantity
    if final_quantity < 0 
      self.errors.add(:generic_errors, "Kuantitas akhir tidak boleh negative")
      return false 
    end 
    
    return true 
  end
  
  def unconfirm_object
    return self if not self.unconfirmable?
    
    self.is_confirmed = false 
    self.confirmed_at = nil 
    self.save
    
    stock_mutation = StockMutation.get_by_source_document_detail( self, STOCK_MUTATION_ITEM_CASE[:ready] )
    
    item.reverse_stock_mutation( stock_mutation )
    warehouse_item.reverse_stock_mutation( stock_mutation )
    stock_mutation.destroy
    
  end
  
  def self.active_objects
    return self 
  end
  
   
end
