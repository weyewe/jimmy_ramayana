class DeliveryOrder < ActiveRecord::Base
  belongs_to :sales_order
  has_many :delivery_order_details 
  
  validates_presence_of :delivery_date, :sales_order_id, :warehouse_id  
  validate :valid_sales_order_id 
  validate :valid_warehouse_id
  
  belongs_to :warehouse 
  
  def valid_sales_order_id
    return  if not sales_order_id.present? 
    object = SalesOrder.find_by_id sales_order_id
    
    if object.nil?
      self.errors.add(:sales_order_id, "Harus ada dan valid")
    end
  end
  
  def valid_warehouse_id
    return  if not warehouse_id.present? 
    object = Warehouse.find_by_id warehouse_id
    
    if object.nil?
      self.errors.add(:warehouse_id, "Harus ada dan valid")
    end
  end
  
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.delivery_date = params[:delivery_date]
    new_object.sales_order_id = params[:sales_order_id]
    new_object.description = params[:description]
    new_object.warehouse_id = params[:warehouse_id]
 
    new_object.save 
    
    return new_object 
  end
  
  def update_object(params )
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah di konfirmasi")
      return self 
    end
    
    self.delivery_date = params[:delivery_date]
    self.sales_order_id = params[:sales_order_id]
    self.description = params[:description]
    self.warehouse_id = params[:warehouse_id]
    self.save 
    
    return self
  end
  
  def all_delivery_order_details_deletable?
    self.delivery_order_details.each do |x|
      return x.deletable? if not x.deletable?
    end
    
    return true
  end
  
  
  def delete_object
    if self.is_confirmed?
      self.errors.add(:generic_errors, "sudah di konfirmasi")
      return self
    else
      self.delivery_order_details.each {|x| x.delete_object}
      self.destroy 
    end
  end
  
  def all_delivery_order_details_confirmable?
    self.delivery_order_details.each do |x|
      return x.confirmable? if not x.confirmable?
    end
    
    return true 
  end
  
  
  
  def confirm_object( params )
    return if self.is_deleted? 

    
    if self.delivery_order_details.count == 0 
      self.errors.add(:generic_errors, "Belum ada detail")
      return self
    end
    
    if self.is_confirmed? 
      self.errors.add(:generic_errors, "Sudah konfirmasi")
      return self 
    end
    
    if self.all_delivery_order_details_confirmable?
      if not params[:confirmed_at].present?
        self.errors.add(:confirmed_at, "Harus ada tanggal konfirmasi")
        return self
      end
      
      self.is_confirmed = true 
      self.confirmed_at = params[:confirmed_at]
      self.save 
      self.delivery_order_details.each {|x| x.confirm_object( params[:confirmed_at]) }
    else
      self.errors.add(:generic_errors, "Ada purchase receival detail yang tidak bisa di konfirmasi")
      return self 
    end
  end
  
  def all_delivery_order_details_unconfirmable?
    self.delivery_order_details.each do |x|
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
    
    if self.all_delivery_order_details_unconfirmable?
      
      self.is_confirmed = false 
      self.confirmed_at = nil 
      self.save 
      self.delivery_order_details.each {|x| x.unconfirm_object }
    else
      self.errors.add(:generic_errors, "Ada purchase receival detail yang tidak bisa di batalkan ")
      return self 
    end
  end
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
  
end
