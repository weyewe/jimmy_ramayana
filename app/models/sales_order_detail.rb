class SalesOrderDetail < ActiveRecord::Base
  belongs_to :sales_order 
  belongs_to :item 
  has_many :delivery_order_details
  
  validates_presence_of :quantity,  :item_id 
  
  validate :non_zero_quantity
  validate :unique_ordered_item 
  validate :can_not_create_if_parent_is_confirmed
  
  def can_not_create_if_parent_is_confirmed
    return if not self.sales_order_id.present?
    return if self.persisted?
    
    if sales_order.is_confirmed?
      self.errors.add(:generic_errors, "Sales Order sudah konfirmasi")
      return self 
    end
  end
  
  def non_zero_quantity
    return if not quantity.present? 
    
    if quantity <= 0 
      self.errors.add(:quantity, "Jumlah tidak boleh 0")
      return self 
    end
  end
  
  def unique_ordered_item
    return if not item_id.present? 
    
    ordered_detail_count  = SalesOrderDetail.where(
      :item_id => item_id,
      :sales_order_id => sales_order_id
    ).count 
    
    ordered_detail = SalesOrderDetail.where(
      :item_id => item_id,
      :sales_order_id => sales_order_id
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
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.sales_order_id = params[:sales_order_id ]
    new_object.item_id = params[:item_id]
    new_object.quantity = params[:quantity]
    new_object.discount = params[:discount]
    new_object.unit_price = params[:unit_price]
    if new_object.save 
      new_object.pending_delivery = new_object.quantity
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
      self.pending_delivery = self.quantity
      self.save
    end
  end
   
  
  
  
  def delete_object
    if not self.is_confirmed?
      self.destroy 
    else
      self.errors.add(:generic_errors, "Sudah konfirmasi. Tidak bisa delete")
      return self 
    end
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
      STOCK_MUTATION_ITEM_CASE[:pending_delivery],   # stock_mutation_item_case
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
    if pending_delivery != quantity
      self.errors.add(:generic_errors, "Sudah ada penerimaan barang")
      return false 
    end
    
    if delivery_order_details.count != 0
      self.errors.add(:generic_errors, "sudah ada pengiriman barang")
      return false 
    end
    
    return true 
  end
  
  def unconfirm_object
    return self if not self.unconfirmable?
    
    self.is_confirmed = false 
    self.confirmed_at = nil 
    self.save 
    
    stock_mutation = StockMutation.get_by_source_document_detail( self , STOCK_MUTATION_ITEM_CASE[:pending_delivery] ) 
    item.reverse_stock_mutation( stock_mutation )
    stock_mutation.destroy 
    
  end
  
  def execute_delivery(do_detail_quantity)
    self.pending_delivery -= do_detail_quantity 
    self.save
  end
  
  def self.active_objects
    self
  end
end
