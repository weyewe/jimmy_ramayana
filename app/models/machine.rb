
class Machine < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name 
  
  has_many :components
  has_many :assets
  
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.brand            = params[:brand] 
    new_object.name            = params[:name] 
    new_object.description            = params[:description]
     
    new_object.save
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.name  = params[:name]
    self.brand = params[:brand]
    self.description      = params[:description    ]
    self.save
    
    return self
  end
  
  def delete_object
    if self.components.count != 0 
      self.errors.add(:generic_errors, "Sudah ada komponen")
      return self 
    end
    
    
    
    self.destroy 
  end 
  
  
  def self.active_objects
    self
  end
end 