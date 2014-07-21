class ItemType < ActiveRecord::Base
  attr_accessible :name, :description 
   
  validates_presence_of :name 
  validates_uniqueness_of :name 
  has_many :items 
  
  
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.name    =  ( params[:name].present? ? params[:name].to_s.upcase : nil )  
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
    
    if self.items.count != 0 
      self.errors.add(:generic_errors, "Sudah ada item")
      return self 
    end
    
    self.is_deleted  = true 
    self.save  
    
  end 
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
end
