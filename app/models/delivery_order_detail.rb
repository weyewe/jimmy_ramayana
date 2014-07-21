class DeliveryOrderDetail < ActiveRecord::Base
  belongs_to :sales_order_detail
  belongs_to :delivery_order
  
  validates_presence_of :sales_order_detail_id, :quantity, :delivery_order_id 
  
  validate :quantity_does_not_exceed_ordered_quantity 
  validate :quantity_non_negative
  validate :unique_sales_order_detail
  validate :sales_order_detail_come_from_the_same_sales_order
  validate :enough_ready_item_in_warehouse
  validate :can_not_create_if_parent_is_confirmed
  
  def can_not_create_if_parent_is_confirmed
    return if not self.delivery_order_id.present?
    return if self.persisted?
    
    if delivery_order.is_confirmed?
      self.errors.add(:generic_errors, "Delivery Order sudah konfirmasi")
      return self 
    end
  end
  
  
  
  def quantity_does_not_exceed_ordered_quantity
    return if not quantity.present?
    return if not sales_order_detail_id.present? 
    
    pending_delivery_quantity = sales_order_detail.pending_delivery
    if quantity > pending_delivery_quantity
      self.errors.add(:quantity, "Tidak boleh lebih dari #{pending_delivery_quantity}")
      return self
    end
  end
  
  def quantity_non_negative
    return if not quantity.present?
    
    if quantity <= 0 
      self.errors.add(:quantity, "Tidak boleh lebih kecil dari 0")
      return self 
    end
  end
  
  
  def unique_sales_order_detail
    return if not sales_order_detail_id.present? 
    return if not delivery_order_id.present? 
    
    delivery_detail_count  = DeliveryOrderDetail.where(
      :sales_order_detail_id => sales_order_detail_id,
      :delivery_order_id => delivery_order_id
    ).count 
    
    delivery_detail = DeliveryOrderDetail.where(
      :sales_order_detail_id => sales_order_detail_id,
      :delivery_order_id => delivery_order_id
    ).first
    
    if self.persisted? and delivery_detail.id != self.id   and delivery_detail_count == 1
      self.errors.add(:sales_order_detail_id, "Item harus uniq dalam 1 pemesanan")
      return self 
    end
    
    # there is item with such item_id in the database
    if not self.persisted? and delivery_detail_count != 0 
      self.errors.add(:sales_order_detail_id, "Item harus uniq dalam 1 pemesanan")
      return self
    end
  end
  
  
  def sales_order_detail_come_from_the_same_sales_order
    return if not sales_order_detail_id.present?
    return if not delivery_order_id.present? 
    
    parent_sales_order_id = self.delivery_order.sales_order_id
    
    if parent_sales_order_id != self.sales_order_detail.sales_order_id
      self.errors.add(:sales_order_detail_id, "Harus berasal dari purchase order yang sama dengan penerimaan")
      return self 
    end
  end
  
  def warehouse_item
    selected_warehouse_item = WarehouseItem.where(
      :item_id => self.sales_order_detail.item_id,
      :warehouse_id => self.delivery_order.warehouse_id
    ).first 
    
    if selected_warehouse_item.nil?
      return WarehouseItem.create_object(
        :item_id => self.sales_order_detail.item_id,
        :warehouse_id =>  self.delivery_order.warehouse_id
      )
    else
      return selected_warehouse_item
    end
    
  end
  
  
  def enough_ready_item_in_warehouse
    return if not sales_order_detail_id.present?
    return if not delivery_order_id.present? 
    
    if warehouse_item.ready  < self.quantity
      self.errors.add(:quantity, "Hanya ada #{warehouse_item.ready} di #{delivery_order.warehouse.name}")
      return self 
    end
  end
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.delivery_order_id = params[:delivery_order_id ]
    new_object.sales_order_detail_id = params[:sales_order_detail_id]
    new_object.quantity = params[:quantity]
    
    new_object.save  
    
    return new_object
  end
  
  
  def update_object(params)
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Tidak bisa update")
      return self 
    end
     
    self.sales_order_detail_id = params[:sales_order_detail_id]
    self.quantity = params[:quantity]
    
    self.save 
  end
   
  
  
  
  def delete_object
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah konfirmasi. Tidak bisa delete")
      return self 
    end
    
    self.destroy 
  end
  
  
  
  def confirmable? 
    if sales_order_detail.pending_delivery - quantity < 0 
      return false 
    end
      
    return true
  end
  
  
  def post_confirm_update_stock_mutation
    item = self.sales_order_detail.item  
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:deduction] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:ready] ,  # stock_mutation_item_case
      delivery_order.warehouse_id 
     ) 
    item.update_stock_mutation( stock_mutation )
    warehouse_item.update_stock_mutation( stock_mutation )
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:deduction] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:pending_delivery] ,  # stock_mutation_item_case
      nil 
     )
    item.update_stock_mutation( stock_mutation )
    
    so_detail = sales_order_detail 
    
    so_detail.execute_delivery( -1* self.quantity ) 
    
    
  end
  
  
  def post_confirm_update_price_mutation
    item = self.sales_order_detail.item  
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:deduction] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:ready]   # stock_mutation_item_case
     ) 
    item.update_stock_mutation( stock_mutation )
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:deduction] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:pending_delivery]   # stock_mutation_item_case
     )
    item.update_stock_mutation( stock_mutation )
  end
   
  
  def confirm_object(confirmation_datetime)
    return self if not self.confirmable?
    
    self.is_confirmed = true 
    self.confirmed_at = confirmation_datetime
    self.save 
    
    self.post_confirm_update_stock_mutation
    # self.post_confirm_update_price_mutation 
    
    # po_detail =self.sales_order_detail
    # po_detail.pending_delivery -= self.quantity 
    so_detail = self.sales_order_detail 
    so_detail.execute_delivery( self.quantity ) 
  end
  
  def unconfirmable?
    # if pending_delivery != quantity
    #   self.errors.add(:generic_errors, "Sudah ada penerimaan barang")
    #   return false 
    # end
    
    return true 
  end
  
  def unconfirm_object
    return self if not self.unconfirmable?
    
    self.is_confirmed = false 
    self.confirmed_at = nil 
    self.save 
    
    item = sales_order_detail.item 
    
    stock_mutation = StockMutation.get_by_source_document_detail( self, STOCK_MUTATION_ITEM_CASE[:ready] ) 
    item.reverse_stock_mutation( stock_mutation )
    warehouse_item.reverse_stock_mutation( stock_mutation )
    stock_mutation.destroy 
    
    item.reload 
    
    stock_mutation = StockMutation.get_by_source_document_detail( self, STOCK_MUTATION_ITEM_CASE[:pending_delivery] ) 
    item.reverse_stock_mutation( stock_mutation )
    
    stock_mutation.destroy
    
    so_detail = self.sales_order_detail
    so_detail.execute_delivery( -1* self.quantity ) 
    
    
    
  end
  
  def self.active_objects
    self
  end
end
