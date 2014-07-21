
class MaintenanceDetail < ActiveRecord::Base
  validates_presence_of :maintenance_id  
  validates_presence_of :component_id  
  
  belongs_to :maintenance
  belongs_to :component  
  
  validate :maintenance_is_not_confirmed_upon_save
  validate :can_not_create_if_parent_is_confirmed
  
  def can_not_create_if_parent_is_confirmed
    return if not self.maintenance_id.present?
    return if self.persisted?
    
    if maintenance.is_confirmed?
      self.errors.add(:generic_errors, "Purchase Order sudah konfirmasi")
      return self 
    end
  end
  
  
  def maintenance_is_not_confirmed_upon_save
    return if maintenance_id.nil?
    
    if maintenance.is_confirmed?
      self.errors.add(:generic_errors, "maintenance sudah di konfirmasi")
      return self 
    end
  end
 
  
  def self.create_object( params ) 
    new_object           = self.new
    
    


    new_object.maintenance_id = params[:maintenance_id] 
    new_object.component_id   = params[:component_id] 
    
    new_object.save 
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    # self.asset_id            = params[:asset_id] 
    # self.complaint_date            = params[:complaint_date] 
    # self.complaint            = params[:complaint]
    # self.complaint_case            = params[:complaint_case]
    # self.save
    # 
    # return self
  end
  
  
  def validate_update_maintenance_result
    puts "\n\nInside validate_update_maintenance_result"
    puts "inspection: #{self}"
    puts "diagnosis_case: #{self.diagnosis_case}"
    puts "solution_case: #{self.solution_case}"
    
    if is_replacement_required.present? and is_replacement_required?
      if not replacement_item_id.present?
        self.errors.add(:replacement_item_id, "harus ada")
      end
      
      replacement_item = Item.find_by_id replacement_item_id
      if replacement_item.nil?
        self.errors.add(:replacement_item_id, "harus ada") 
      end
    end
    
   
    
    if not diagnosis_case.present?
      self.errors.add(:diagnosis_case, "Harus ada")
    else
      if not [
        DIAGNOSIS_CASE[:all_ok],
        DIAGNOSIS_CASE[:require_fix],
        DIAGNOSIS_CASE[:require_replacement],
        ].include?(self.diagnosis_case)
        self.errors.add(:diagnosis_case, "Harus valid")
      end
    end
    
    if not solution_case.present?
      self.errors.add(:solution_case, "Harus ada")
    else
      if  not [
        SOLUTION_CASE[:pending],
        SOLUTION_CASE[:solved],
        ].include?(self.solution_case)
        self.errors.add(:solution_case, "Harus valid")
      end
    end
  end
  
  def update_maintenance_result( params ) 
    puts "The params: #{params}"
    
    if self.maintenance.is_confirmed?
      self.errors.add(:generic_errors, "Maintenance sudah di konfirmasi")
      return self 
    end
    
    self.diagnosis                  =  params[:diagnosis                ]
    self.diagnosis_case             =  params[:diagnosis_case           ]
    self.solution                   =  params[:solution                 ]
    self.solution_case              =  params[:solution_case            ]
    self.is_replacement_required    =  params[:is_replacement_required  ]
    self.replacement_item_id        =  params[:replacement_item_id      ]
    
    self.validate_update_maintenance_result 
    
    puts "Gonna call this shite"
    if   not self.is_replacement_required?
      puts "333 gonna assign it"
      self.replacement_item_id = nil 
    end
    
    puts "replacement_item_id : #{replacement_item_id}"
    
    if self.errors.size == 0 
      self.save
    end
    
    return self 
  end
  
  def delete_object
    if self.maintenance.is_confirmed?s
      self.errors.add(:generic_errors, "Sudah konfirmasi")
      return self
    end
    
     
    
    self.destroy
  end 
  
  def warehouse_item
    return nil if not is_replacement_required.present? 
    return nil if  not is_replacement_required?
    
    selected_warehouse_item = WarehouseItem.where(
      :item_id => self.replacement_item_id ,
      :warehouse_id => self.maintenance.warehouse_id
    ).first 
    
    if selected_warehouse_item.nil?
      return WarehouseItem.create_object(
        :item_id => self.replacement_item_id ,
        :warehouse_id =>  self.maintenance.warehouse_id
      )
    else
      return selected_warehouse_item
    end
    
  end
  
  def confirmable?
     if is_replacement_required.present? and is_replacement_required? and warehouse_item.ready -1 < 0 
       self.errors.add(:generic_errors, "Tidak ada cukup item untuk replacement")
       return self 
     end
  end
  
  
  def replacement_item
    Item.find_by_id self.replacement_item_id
  end
  
  def confirm 
    if is_replacement_required? 
      
      stock_mutation = StockMutation.create_object( 
        replacement_item, # the item 
        self, # source_document_detail 
        STOCK_MUTATION_CASE[:deduction] , # stock_mutation_case,
        STOCK_MUTATION_ITEM_CASE[:ready]   # stock_mutation_item_case
       ) 
      replacement_item.update_stock_mutation( stock_mutation )
      warehouse_item.update_stock_mutation( stock_mutation )
      
    end
  end
  
  def unconfirm
    if is_replacement_required?
      stock_mutation = StockMutation.get_by_source_document_detail( self, STOCK_MUTATION_ITEM_CASE[:ready] )
      replacement_item.reverse_stock_mutation( stock_mutation )
      warehouse_item.reverse_stock_mutation( stock_mutation )
      stock_mutation.destroy
    end
  end
  
  
  def self.active_objects
    self
  end
end