class PurchaseOrderDetail < ActiveRecord::Base
  belongs_to :purchase_order 
  belongs_to :item 
  has_many :purchase_receival_details
  
  validates_presence_of :quantity,  :item_id 
  
  validate :non_zero_quantity
  validate :unique_ordered_item 
  validate :can_not_create_if_parent_is_confirmed
  
  
  
  def non_zero_quantity
    return if not quantity.present? 
    
    if quantity <= 0 
      self.errors.add(:quantity, "Jumlah tidak boleh 0")
      return self 
    end
  end
  
   
  def unique_ordered_item
    return if not item_id.present? 
    
    ordered_detail_count  = PurchaseOrderDetail.where(
      :item_id => item_id,
      :purchase_order_id => purchase_order_id
    ).count 
    
    ordered_detail = PurchaseOrderDetail.where(
      :item_id => item_id,
      :purchase_order_id => purchase_order_id
    ).first
    
    if self.persisted? and ordered_detail.id != self.id   and ordered_detail_count == 1
      self.errors.add(:item_id, "Item harus uniq dalam 1 pemesanan")
      return self 
    end
    
    # there is item with such item_id in the database
    if not self.persisted? and ordered_detail_count != 0 
      self.errors.add(:item_id, "Item harus uniq dalam 1 pemesanan")
      return self
    end
  end
  
  def can_not_create_if_parent_is_confirmed
    return if not self.purchase_order_id.present?
    return if self.persisted?
    
    if purchase_order.is_confirmed?
      self.errors.add(:generic_errors, "Purchase Order sudah konfirmasi")
      return self 
    end
  end
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.purchase_order_id = params[:purchase_order_id ]
    new_object.item_id = params[:item_id]
    new_object.quantity = params[:quantity]
    new_object.discount = params[:discount]
    new_object.unit_price = params[:unit_price]
    
    
  
    if new_object.save 
      new_object.pending_receival = new_object.quantity
      new_object.save
    end
    
    return new_object
  end
  
  
  def update_object(params)
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Tidak bisa update")
      return self 
    end
     
    self.item_id = params[:item_id]
    self.quantity = params[:quantity]
    self.discount = params[:discount]
    self.unit_price = params[:unit_price]
    if self.save
      self.pending_receival = self.quantity
      self.save
    end
  end
   
  
  
  
  def delete_object
    
    if self.purchase_receival_details.count != 0 
      self.errors.add(:generic_errors, "Sudah ada penerimaan")
      return self 
    end
    
    if not self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah konfirmasi. Tidak bisa delete")
      return self 
    end
    
    self.destroy 
  end
  
  
  
  def confirmable? 
    return true
  end
  
  
  def post_confirm_update_stock_mutation
    item = self.item 
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:addition] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:pending_receival],   # stock_mutation_item_case
     nil
     ) 
    item.update_stock_mutation( stock_mutation )
  end
  
   
  
  def confirm_object(confirmation_datetime)
    return self if not self.confirmable?
    
    self.is_confirmed = true 
    self.confirmed_at = confirmation_datetime
    self.save 
    
    self.post_confirm_update_stock_mutation 
  end
  
  def unconfirmable?
    if item.pending_receival - quantity < 0 
      self.errors.add(:generic_errors, "Sudah ada penerimaan barang")
      return false 
    end
    
    if self.purchase_receival_details.count != 0 
      self.errors.add(:generic_errors, "Sudah ada penerimaan")
      return false  
    end
    
    # if the resulting unconfirm == negative, can't be 
    
    return true 
  end
  
  def unconfirm_object
    return self if not self.unconfirmable?
    
    self.is_confirmed = false 
    self.confirmed_at = nil 
    self.save 
    
    stock_mutation = StockMutation.get_by_source_document_detail( self , STOCK_MUTATION_ITEM_CASE[:pending_receival] ) 
    item.reverse_stock_mutation( stock_mutation )
    stock_mutation.destroy 
    
  end
  
  def execute_receival(pr_detail_quantity)
    self.pending_receival -= pr_detail_quantity 
    self.save
  end
  
  def self.active_objects
    self 
  end
end
