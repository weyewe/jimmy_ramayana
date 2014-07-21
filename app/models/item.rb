class Item < ActiveRecord::Base
  has_many :warehouses, :through => :warehouse_items
  has_many :warehouse_items 
  belongs_to :item_type
  
  has_many :price_mutations 
  
  validate :uniq_sku_in_active_objects
  has_many :stock_mutations
  
  has_many :compatibilities
  has_many :components, :through => :compatibilities
  validate :valid_item_type_id 
  
  validates_presence_of :sku , :item_type_id 
  
  def valid_item_type_id
    return if not item_type_id.present?
    
    object = ItemType.find_by_id item_type_id
    
    if object.nil?
      self.errros.add(:generic_errors, "Harus valid")
      return self 
    end
  end
  
  
  def uniq_sku_in_active_objects
    return if not sku.present?
    
    total_duplicate_count = Item.where(:sku => self.sku, :is_deleted => false).count
    target = Item.where(:sku => self.sku).first
    
    if not self.persisted? and total_duplicate_count != 0 
      self.errors.add(:sku, "Harus unik")
      return self 
    end
    
    if self.persisted? and target.id != self.id and total_duplicate_count  ==  1 
      self.errors.add(:sku, "Harus unik")
      return self 
    end
  end
   
  
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.sku = params[:sku]
    new_object.description = params[:description]
    new_object.item_type_id = params[:item_type_id]
    new_object.save
    
    return new_object 
  end
  
  def update_object(params)
    self.sku = params[:sku]
    self.description = params[:description]
    self.save
    
    return self 
  end
  
  def delete_object
    puts "checking if stock_mutations is zero"
    if self.stock_mutations.count != 0 
      self.errors.add(:generic_errors, "Sudah ada stock mutasi")
      return self
    end
    
    puts "stock_mutations: #{stock_mutations.count}"
    
    puts "this is awesome.. gonna delete"
    self.is_deleted = true
    self.save 
  end
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
  
  
=begin
StockMutation related
=end

  def update_quantity_according_to_item_case(stock_mutation_item_case, mutation_quantity)
    if stock_mutation_item_case == STOCK_MUTATION_ITEM_CASE[:pending_receival]
      self.pending_receival += mutation_quantity 
    elsif  stock_mutation_item_case == STOCK_MUTATION_ITEM_CASE[:ready]
      self.ready += mutation_quantity 
    elsif  stock_mutation_item_case == STOCK_MUTATION_ITEM_CASE[:pending_delivery]
      self.pending_delivery += mutation_quantity
    end
  
    self.save 
  end


  def reverse_stock_mutation(stock_mutation)
    multiplier = 1
    if stock_mutation.case == STOCK_MUTATION_CASE[:addition]
      multiplier = -1 
    end
    
    self.update_quantity_according_to_item_case( stock_mutation.item_case , multiplier * stock_mutation.quantity )
  end
  
  
  def update_stock_mutation( stock_mutation ) 
    multiplier = 1
    if stock_mutation.case == STOCK_MUTATION_CASE[:deduction]
      multiplier = -1 
    end
    
    self.update_quantity_according_to_item_case( stock_mutation.item_case , multiplier * stock_mutation.quantity )
  end
   
end
