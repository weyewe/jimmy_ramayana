
class AssetDetail < ActiveRecord::Base
  validates_presence_of :asset_id  
  validates_presence_of :component_id  
  
  belongs_to :asset
  belongs_to :component  
  
  validate :unique_component
  
  def unique_component
    return if not component_id.present? 
    return if not asset_id.present? 
    
    component_count  = AssetDetail.where(
      :component_id => component_id,
      :asset_id => asset_id
    ).count 
    
    component_detail = AssetDetail.where(
      :component_id => component_id,
      :asset_id => asset_id
    ).first
    
    if self.persisted? and component_detail.id != self.id   and component_count == 1
      self.errors.add(:component_id, "Component harus uniq dalam 1 asset")
      return self 
    end
    
    # there is item with such item_id in the database
    if not self.persisted? and component_count != 0 
      self.errors.add(:component_id, "Component harus uniq dalam 1 pemesanan")
      return self
    end
  end
  
  
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.asset_id            = params[:asset_id] 
    
    
    new_object.component_id            = params[:component_id]  
     
    new_object.save
      
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.asset_id            = params[:asset_id] 
    self.component_id            = params[:component_id] 
    self.save
    
    return self
  end
  
  def delete_object
    self.destroy 
  end 
  
  def assign_initial_item( params ) 
    
    self.initial_item_id = params[:initial_item_id]
    self.current_item_id = params[:initial_item_id]
    
    
    if initial_item.nil?
      self.errors.add(:generic_errors, "harus memilih item")
      return self 
    end
    
    compatibility_count = self.component.compatibilities.where(:item_id => params[:initial_item_id]).count
    
    if compatibility_count == 0
      self.errors.add(:initial_item_id, "Tidak memiliki kompatibilitas")
      return self 
    end
    
    
    
    self.save 
  end
  
  def update_assigned_item( maintenance_detail ) 
    self.current_item_id = maintenance_detail.replacement_item_id
    self.save 
  end
  
  def revert_assigned_item
    current_component_id = self.component_id
    last_maintenance_detail = MaintenanceDetail.joins(:maintenance).where{
      (maintenance.is_confirmed.eq true ) & 
      (component_id.eq current_component_id) &
      (is_replacement_required.eq true)
    }.order("id DESC").first 
    
    if last_maintenance_detail.nil?
      self.current_item_id = self.initial_item_id
      self.maintenance_detail_id = nil 
      self.save 
    else
      self.current_item_id = last_maintenance_detail.replacement_item_id
      self.maintenance_detail_id = last_maintenance_detail.id 
      self.save  
    end
  end
   
  
  
  def self.active_objects
    self 
  end
  
  def initial_item
    return nil if initial_item_id.nil?
    
    return Item.find_by_id initial_item_id 
  end
  
  
  def current_item
    return nil if current_item_id.nil?
    
    return Item.find_by_id current_item_id
  end
end