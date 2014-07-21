class PurchaseReceival < ActiveRecord::Base
  belongs_to :purchase_order
  belongs_to :warehouse
  has_many :purchase_receival_details 
  
  
  validates_presence_of :receival_date, :purchase_order_id , :warehouse_id 
  
  validate :valid_purchase_order_id, :valid_warehouse_id
  validate :confirmed_purchase_order
  
  def valid_purchase_order_id
    return  if not purchase_order_id.present? 
    object = PurchaseOrder.find_by_id purchase_order_id
    
    if object.nil?
      self.errors.add(:purchase_order_id, "Harus ada dan valid")
      return self 
    end
  end
  
  def valid_warehouse_id
    return  if not warehouse_id.present? 
    object = Warehouse.find_by_id warehouse_id
    
    if object.nil?
      self.errors.add(:warehouse_id, "Harus ada dan valid")
    end
  end
  
  def confirmed_purchase_order
    return if not purchase_order_id.present? 
    return if  purchase_order.nil?
    
    if not purchase_order.is_confirmed?
      self.errors.add(:generic_errors, "Purchase Order harus sudah di konfirmasi")
      return self 
    end
  end
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.receival_date = params[:receival_date]
    new_object.purchase_order_id = params[:purchase_order_id]
    new_object.description = params[:description]
    new_object.warehouse_id = params[:warehouse_id ]
 
    new_object.save 
    
    return new_object 
  end
  
  def update_object(params )
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah di konfirmasi")
      return self 
    end
    
    self.receival_date = params[:receival_date]
    self.purchase_order_id = params[:purchase_order_id]
    self.description = params[:description]
    self.warehouse_id = params[:warehouse_id]
    self.save 
    
    return self
  end
  
  def all_purchase_receival_details_deletable?
    self.purchase_order_details.each do |x|
      return x.deletable? if not x.deletable?
    end
    
    return true
  end
  
  
  def delete_object
    if self.is_confirmed?
      self.errors.add(:generic_errors, "sudah di konfirmasi")
      return self
    else
      self.purchase_receival_details.each {|x| x.delete_object}
      self.destroy 
    end
  end
  
  def all_purchase_receival_details_confirmable?
    self.purchase_receival_details.each do |x|
      return x.confirmable? if not x.confirmable?
    end
    
    return true 
  end
  
  
  
  def confirm_object( params )
    return if self.is_deleted? 

    
    if self.purchase_receival_details.count == 0 
      self.errors.add(:generic_errors, "Belum ada detail")
      return self
    end
    
    if self.is_confirmed? 
      self.errors.add(:generic_errors, "Sudah konfirmasi")
      return self 
    end
    
    if self.all_purchase_receival_details_confirmable?
      if not params[:confirmed_at].present?
        self.errors.add(:confirmed_at, "Harus ada tanggal konfirmasi")
        return self
      end
      
      self.is_confirmed = true 
      self.confirmed_at = params[:confirmed_at]
      self.save 
      self.purchase_receival_details.each {|x| x.confirm_object( params[:confirmed_at]) }
    else
      self.errors.add(:generic_errors, "Ada purchase receival detail yang tidak bisa di konfirmasi")
      return self 
    end
  end
  
  def all_purchase_receival_details_unconfirmable?
    self.purchase_receival_details.each do |x|
      return  x.unconfirmable? if not x.unconfirmable?
    end
    
    return true 
  end
  
  
  def unconfirm_object 
    return if self.is_deleted?
    
    if not self.is_confirmed? 
      self.errors.add(:generic_errors, "Belum konfirmasi")
      return self 
    end
    
    if self.all_purchase_receival_details_unconfirmable?
      
      self.is_confirmed = false 
      self.confirmed_at = nil 
      self.save 
      self.purchase_receival_details.each {|x| x.unconfirm_object }
    else
      self.errors.add(:generic_errors, "Ada purchase receival detail yang tidak bisa di batalkan ")
      return self 
    end
  end
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
  
end
