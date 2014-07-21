
class Component < ActiveRecord::Base
  validates_presence_of :name, :machine_id 
  
  has_many :items, :through => :compatibilities 
  has_many :compatibilities 
  
  belongs_to :machine
  has_many :maintenance_details 
  has_many :asset_details
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.name            = params[:name] 
    new_object.description            = params[:description]
    new_object.machine_id            = params[:machine_id]
     
    if new_object.save
      new_object.machine.assets.each do |asset|
        AssetDetail.create_object(
          :component_id => new_object.id,
          :asset_id => asset.id
        )
      end
    end
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.name  = params[:name]
    self.description      = params[:description    ]
    self.machine_id      = params[:machine_id    ]
    self.save
    
    return self
  end
  
  def delete_object
    
    if self.compatibilities.count != 0 
      self.errors.add(:generic_errors, "Sudah ada kompatibilitas")
      return self 
    end
    
    if self.maintenance_details.count != 0 
      self.errors.add(:generic_errors, "Sudah ada maintenance untuk komponen ini")
      return self 
    end
    
    
    
    if self.asset_details.count != 0 
      self.errors.add(:generic_errors, "Sudah ada mesin yang memiliki component terdaftar ini")
      return self 
    end
    
    self.destroy 
    
  end 
  
  
  def self.active_objects
    self 
  end
end
