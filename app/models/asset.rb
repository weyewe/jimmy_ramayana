
class Asset < ActiveRecord::Base
  validates_presence_of :machine_id, :contact_id, :code 
  validates_uniqueness_of :code
  
  belongs_to :contact
  belongs_to :machine 
  has_many :maintenances
  has_many :asset_details 
  
  
  validate :machine_component_has_been_created
  
  
  def machine_component_has_been_created
    return if not self.machine_id.present? 
    return if self.persisted? 
    
    if self.machine.components.count == 0 
      self.errors.add(:generic_errors, "There is no component registered in the machine")
      return self 
    end
  end
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.machine_id            = params[:machine_id] 
    new_object.contact_id            = params[:contact_id] 
    new_object.description            = params[:description]
    new_object.code = ( params[:code].present? ? params[:code   ].to_s.upcase : nil )  #  params[:code]
    if new_object.save
      new_object.machine.components.each do |component|
        AssetDetail.create_object(
          :component_id => component.id,
          :asset_id => new_object.id
        )
      end
    end
      
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.contact_id = params[:contact_id]
    self.description      = params[:description    ]
    self.code = ( params[:code].present? ? params[:code   ].to_s.upcase : nil )
    self.save
    
    return self
  end
  
  def delete_object
     
    
    if self.maintenances.count != 0 
      self.errors.add(:generic_errors, "sudah ada maintenance")
      return self 
    end
    
    
    
    self.asset_details.each {|x| x.destroy }
    self.destroy 
  end 
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
  
  def all_details_initialized?
    return true if self.asset_details.where{
                            initial_item_id.eq nil
                          }.count == 0  
                          
    return false  
  end
end