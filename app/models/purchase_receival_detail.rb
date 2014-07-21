class PurchaseReceivalDetail < ActiveRecord::Base
  belongs_to :purchase_order_detail
  belongs_to :purchase_receival
  
  validates_presence_of :purchase_order_detail_id, :quantity, :purchase_receival_id 
  
  validate :quantity_does_not_exceed_ordered_quantity 
  validate :quantity_non_negative
  validate :unique_purchase_order_detail
  validate :purchase_order_detail_come_from_the_same_purchase_order
  validate :can_not_create_if_parent_is_confirmed
  # validate :can_not_select_unconfirmed_purchase_order_detail
   
  
  after_save :create_warehouse_item_if_not_existed_yet
  
  def can_not_create_if_parent_is_confirmed
    return if not self.purchase_receival_id.present?
    return if self.persisted?
    
    if purchase_receival.is_confirmed?
      self.errors.add(:generic_errors, "Purchase Order sudah konfirmasi")
      return self 
    end
  end
  
  
  
  
  
  def quantity_does_not_exceed_ordered_quantity
    return if not quantity.present?
    return if not purchase_order_detail_id.present? 
    
    pending_receival_quantity = purchase_order_detail.pending_receival
    if quantity > pending_receival_quantity
      self.errors.add(:quantity, "Tidak boleh lebih dari #{pending_receival_quantity}")
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
  
  
  def unique_purchase_order_detail
    return if not purchase_order_detail_id.present? 
    return if not purchase_receival_id.present? 
    
    receival_detail_count  = PurchaseReceivalDetail.where(
      :purchase_order_detail_id => purchase_order_detail_id,
      :purchase_receival_id => purchase_receival_id
    ).count 
    
    receival_detail = PurchaseReceivalDetail.where(
      :purchase_order_detail_id => purchase_order_detail_id,
      :purchase_receival_id => purchase_receival_id
    ).first
    
    if self.persisted? and receival_detail.id != self.id   and receival_detail_count == 1
      self.errors.add(:purchase_order_detail_id, "Item harus uniq dalam 1 pemesanan")
      return self 
    end
    
    # there is item with such item_id in the database
    if not self.persisted? and receival_detail_count != 0 
      self.errors.add(:purchase_order_detail_id, "Item harus uniq dalam 1 pemesanan")
      return self
    end
  end
  
  
  def purchase_order_detail_come_from_the_same_purchase_order
    return if not purchase_order_detail_id.present?
    
    parent_purchase_order_id = self.purchase_receival.purchase_order_id
    
    if parent_purchase_order_id != self.purchase_order_detail.purchase_order_id
      self.errors.add(:purchase_order_detail_id, "Harus berasal dari purchase order yang sama dengan penerimaan")
      return self 
    end
  end
  
  def warehouse_item
    selected_warehouse_item = WarehouseItem.where(
      :item_id => self.purchase_order_detail.item_id,
      :warehouse_id => self.purchase_receival.warehouse_id
    ).first 
    
    if selected_warehouse_item.nil?
      return WarehouseItem.create_object(
        :item_id => self.purchase_order_detail.item_id,
        :warehouse_id =>  self.purchase_receival.warehouse_id
      )
    else
      return selected_warehouse_item
    end
    
  end
  
  def create_warehouse_item_if_not_existed_yet
    selected_warehouse_item = WarehouseItem.where(
      :item_id => self.purchase_order_detail.item_id,
      :warehouse_id => self.purchase_receival.warehouse_id
    ).first 
    
    if selected_warehouse_item.nil?
      WarehouseItem.create_object(
        :item_id => self.purchase_order_detail.item_id,
        :warehouse_id =>  self.purchase_receival.warehouse_id
      )
    end
  end
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.purchase_receival_id = params[:purchase_receival_id ]
    new_object.purchase_order_detail_id = params[:purchase_order_detail_id]
    new_object.quantity = params[:quantity]
    
    new_object.save
    
    return new_object
  end
  
  
  def update_object(params)
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Tidak bisa update")
      return self 
    end
     
    self.purchase_order_detail_id = params[:purchase_order_detail_id]
    self.quantity = params[:quantity]
    
    
    self.save 
  end
   
  
  
  
  def delete_object
    if  self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah konfirmasi. Tidak bisa delete")
      return self 
    end
    
    
    
    self.destroy 
  end
  
  
  
  def confirmable? 
    if purchase_order_detail.pending_receival - quantity < 0 
      return false 
    end
      
    return true
  end
  
  
  
  
  def post_confirm_update_stock_mutation
    item = self.purchase_order_detail.item  
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:addition] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:ready],   # stock_mutation_item_case
      purchase_receival.warehouse_id
     ) 
    item.update_stock_mutation( stock_mutation )
    warehouse_item.update_stock_mutation( stock_mutation )
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:deduction] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:pending_receival] ,  # stock_mutation_item_case
      purchase_receival.warehouse_id 
     )
    item.update_stock_mutation( stock_mutation )
    
    
  end
  
  
  # def post_confirm_update_price_mutation
  #   item = self.purchase_order_detail.item  
  #   
  #   stock_mutation = StockMutation.create_object( 
  #     item, # the item 
  #     self, # source_document_detail 
  #     STOCK_MUTATION_CASE[:addition] , # stock_mutation_case,
  #     STOCK_MUTATION_ITEM_CASE[:ready]   # stock_mutation_item_case
  #    ) 
  #   item.update_stock_mutation( stock_mutation )
  #   
  #   stock_mutation = StockMutation.create_object( 
  #     item, # the item 
  #     self, # source_document_detail 
  #     STOCK_MUTATION_CASE[:deduction] , # stock_mutation_case,
  #     STOCK_MUTATION_ITEM_CASE[:pending_receival]   # stock_mutation_item_case
  #    )
  #   item.update_stock_mutation( stock_mutation )
  # end
   
  
  def confirm_object(confirmation_datetime)
    return self if not self.confirmable?
    
    self.is_confirmed = true 
    self.confirmed_at = confirmation_datetime
    self.save 
    
    self.post_confirm_update_stock_mutation
    # self.post_confirm_update_price_mutation 
    
    # po_detail =self.purchase_order_detail
    # po_detail.pending_receival -= self.quantity 
    po_detail = self.purchase_order_detail 
    po_detail.execute_receival( self.quantity ) 
  end
  
  def unconfirmable?
    
    if purchase_order_detail.item.ready - quantity < 0 
      self.errors.add(:generic_errors, "Akan mengakibatkan ready item menjadi 0")
      return false 
    end
    
    if warehouse_item.ready - quantity < 0 
      self.errors.add(:generic_errors, "Akan mengakibatkan ready item menjadi kurang dari 0")
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
    item = purchase_order_detail.item  
    item.reverse_stock_mutation( stock_mutation )
    warehouse_item.reverse_stock_mutation( stock_mutation )
    stock_mutation.destroy 
    
    item.reload 
    
    stock_mutation = StockMutation.get_by_source_document_detail( self, STOCK_MUTATION_ITEM_CASE[:pending_receival] ) 
    item.reverse_stock_mutation( stock_mutation )
    
    
    stock_mutation.destroy
    
    po_detail = self.purchase_order_detail
    po_detail.execute_receival( -1* self.quantity ) 
    
    
    
  end
  
  def self.active_objects
    self
  end
end
