class Warehouse < ActiveRecord::Base
  has_many :items, :through => :warehouse_items 
  has_many :warehouse_items
  has_many :delivery_orders
  has_many :stock_adjustments
  has_many :purchase_receivals 
  
   
  validates_presence_of :name  
  validates_uniqueness_of :name  
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.name    =  ( params[:name].present? ? params[:name   ].to_s.upcase : nil )  
    new_object.description  = params[:description]
    
    new_object.save
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    self.name    =  ( params[:name].present? ? params[:name   ].to_s.upcase : nil  ) 
    self.description  = params[:description]
    
    self.save
    
    return self
  end
  
  def delete_object
    
    if self.warehouse_items.where{ ready.not_eq 0}.count != 0 
      self.errors.add(:generic_errors, "tidak bisa dihapus")
      return self 
    end
    
    self.warehouse_items.each {|x| x.destroy }
    self.destroy 
    
  end 
  
  
  def self.active_objects
    self 
  end
  
  
end
