
class Compatibility < ActiveRecord::Base
  
  validates_presence_of :item_id, :component_id
  belongs_to :item
  belongs_to :component 
  
  
  validate :unique_item_id_component_combination
  
  validate :valid_item_id
  validate :valid_component_id 
  
  
  def valid_item_id
    return  if not item_id.present? 
    object = Item.find_by_id item_id
    
    if object.nil?
      self.errors.add(:item_id, "Harus ada dan valid")
    end
  end
  
  
  def valid_component_id
    return  if not component_id.present? 
    object = Component.find_by_id component_id
    
    if object.nil?
      self.errors.add(:component_id, "Harus ada dan valid")
    end
  end
  
  
  def unique_item_id_component_combination
    return if not ( item_id.present?  and component_id.present? ) 
    
    compatibility_count  = Compatibility.where(
      :item_id => item_id,
      :component_id => component_id
    ).count 
    
    compatibility_detail = Compatibility.where(
      :item_id => item_id,
      :component_id => component_id
    ).first
    
    if self.persisted? and compatibility_detail.id != self.id   and compatibility_count == 1
      self.errors.add(:item_id, "Sudah ada kompatibility seperti ini")
      return self 
    end
    
    # there is item with such item_id in the database
    if not self.persisted? and compatibility_count != 0 
      self.errors.add(:item_id, "Sudah ada kompatibility seperti ini")
      return self
    end
  end
    # 
    # 
    # def unique_item_id_component_combination
    #   return if not ( item_id.present? and component_id.present? )
    #   
    #   compatibility_count = self.class.where(
    #     :item_id => self.item_id,
    #     :component_id => self.component_id
    #   ).count
    #   
    #   if self.persisted? 
    #     if compatibility_count > 1 
    #       self.errors.add(:generic_errors, "Sudah ada kompatibilitas seperti ini")
    #       return self 
    #     end
    #   elsif compatibility_count > 0 
    #     self.errors.add(:generic_errors, "Sudah ada kompatibilitas seperti ini")
    #     return self
    #   end
    # end
    # 
 
  
  def self.create_object( params ) 
    new_object              = self.new
    puts "The params: #{params}"
    
    new_object.item_id      = params[:item_id] 
    new_object.component_id = params[:component_id]

     
    new_object.save
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.item_id  = params[:item_id]
    self.component_id      = params[:component_id    ]
    self.save
    
    return self
  end
  
  def delete_object
    
    # check if there is maintenance_detail using this compatibility
    
    self.destroy  
    
  end 
  
  
  def self.active_objects
    self
  end
end
