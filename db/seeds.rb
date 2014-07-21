role = {
  :system => {
    :administrator => true
  }
}

admin_role = Role.create!(
  :name        => ROLE_NAME[:admin],
  :title       => 'Administrator',
  :description => 'Role for administrator',
  :the_role    => role.to_json
)

role = {
  :passwords => {
    :update => true 
  },
  :works => {
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :work_reports => true ,
    :project_reports => true ,
    :category_reports => true 
  },
  :projects => {
    :search => true 
  },
  :categories => {
    :search => true 
  }
}

data_entry_role = Role.create!(
  :name        => ROLE_NAME[:data_entry],
  :title       => 'Data Entry',
  :description => 'Role for data_entry',
  :the_role    => role.to_json
)



# if Rails.env.development?

  admin = User.create_main_user(  :name => "Admin", :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user


  admin = User.create_main_user(  :name => "Admin2", :email => "admin2@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user
  
  admin = User.create_main_user(  :name => "Admin4", :email => "admin4@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user


  
   item_array = [] 
  (1..3).each do |x|
    item = Item.create_object(
      :sku => "SKU #{x}",
      :description => "Awesome description #{x}"
    )
    
    item_array << item 
  end
  
  puts "Total item: #{Item.count}"
  
  
  contact_array = [] 
  (1..3).each do |x|
    contact = Contact.create_object(
      :name             => "Contact #{x}"           ,
      :description      => "Description #{x}"      ,
      :address          =>  "Address #{x}"        ,
      :shipping_address => "Shipping Address"
    )
    contact_array << contact 
  end
  
  
  puts "Total contact: #{Contact.count}"
  
  machine_array = [] 
  (1..3).each do |x|
    machine = Machine.create_object(
      :name             => "Name #{x}"           ,
      :description      => "Description #{x}"      ,
      :brand          =>  "Brand #{x}"        
    )
    machine_array << machine 
  end
  
  
  puts "Total machine: #{Machine.count}"
  
  Machine.all.each do |x|
    (1..3).each do |y|
      component = Component.create_object(
        :name => "Component Name #{x.id} - #{y}" ,
        :description => "Description #{x.id} - #{y}",
        :machine_id => x.id 
      )
    end
    
  end
  puts "Total component: #{Component.count}"
  
  Component.all.each do |x|
    Compatibility.create_object(
      :item_id => Item.first.id,
      :component_id => x.id 
    )
  end
  
  puts "Total compatibility: #{Compatibility.count}" 
  
  counter  = 0 
  Contact.all.each do |contact|
    Machine.all.each do |machine|
       
      asset = Asset.create_object(
        :machine_id           => machine.id,
        :contact_id           => contact.id,
        :description          =>"awesome",
        :code => "code #{counter}"
      )
      
      counter += 1 
      
      if asset.errors.size != 0 
        asset.errors.messages.each do |x|
          puts "create asset error : #{x}"
        end
      end
      
    end
  end
  

  (1..3).each do |x|
    Warehouse.create_object(
      :name             => "Gudang #{x}"           ,
      :description      => "Description #{x}"       
    )
  end
  
  puts "Total warehouse: #{Warehouse.count}" 
  
  (1..3).each do |x|
    StockAdjustment.create_object(
      :adjustment_date             => DateTime.now - 2.days         ,
      :description      => "description stock adjustment #{x}"      ,
      :warehouse_id => Warehouse.first.id 
    )
  end
  
  puts "Total stock adjustment: #{StockAdjustment.count}" 
  
  item_array  = Item.all 
  StockAdjustment.all.each do |sa|
    (1..3).each do |x|
      StockAdjustmentDetail.create_object(
        :item_id => item_array[x-1].id,
        :quantity => 10, 
        :stock_adjustment_id => sa.id 
      )
    end
  end
  
  puts "Total stock adjustment detail: #{StockAdjustmentDetail.count}"
  
  (1..3).each do |x|
    PurchaseOrder.create_object(
      :purchase_date             => DateTime.now - 6.days         ,
      :description      => "description stock adjustment #{x}"      ,
      :contact_id => Contact.first.id 
    )
  end
  
  puts "Total PO: #{PurchaseOrder.count}" 
  
  item_array  = Item.all 
  PurchaseOrder.all.each do |po|
    (1..3).each do |x|
      PurchaseOrderDetail.create_object(
        :item_id => item_array[x-1].id,
        :quantity => 10, 
        :purchase_order_id => po.id 
      )
      
       
    end
  end
  
  PurchaseOrder.first.confirm_object(:confirmed_at => DateTime.now-2.days)
  PurchaseOrder.last.confirm_object(:confirmed_at => DateTime.now - 1.days)
  
  puts "Total po detail: #{PurchaseOrderDetail.count}"
  puts "Total po confirmed: #{PurchaseOrder.where(:is_confirmed => true).count }"
  
  PurchaseOrder.where(:is_confirmed => true ).each do |po|
    PurchaseReceival.create_object(
      :receival_date             => DateTime.now - 4.days         ,
      :description      => "description purchase_receival #{po.id}"      ,
      :purchase_order_id => po.id,
      :warehouse_id => Warehouse.first.id 
    )
  end
  
  puts "Total PR: #{PurchaseReceival.count}" 
  
  PurchaseReceival.all.each do |pr|
    pr.purchase_order.purchase_order_details.each do |pod|
      PurchaseReceivalDetail.create_object(
        :purchase_order_detail_id => pod.id ,
        :quantity => pod.quantity - 1 , 
        :purchase_receival_id => pr.id 
      )
    end
  end
  
  puts "Total pr detail: #{PurchaseReceivalDetail.count}"
  
  
  
######### for the sales part

(1..3).each do |x|
  SalesOrder.create_object(
    :sales_date             => DateTime.now - 6.days         ,
    :description      => "description stock adjustment #{x}"      ,
    :contact_id => Contact.first.id 
  )
end

puts "Total SO: #{SalesOrder.count}" 

item_array  = Item.all 
SalesOrder.all.each do |po|
  (1..3).each do |x|
    SalesOrderDetail.create_object(
      :item_id => item_array[x-1].id,
      :quantity => 10, 
      :sales_order_id => po.id 
    )
    
     
  end
end

SalesOrder.first.confirm_object(:confirmed_at => DateTime.now-2.days)
SalesOrder.last.confirm_object(:confirmed_at => DateTime.now - 1.days)

puts "Total so detail: #{SalesOrderDetail.count}"
puts "Total so confirmed: #{SalesOrder.where(:is_confirmed => true).count }"

stock_adjustment = StockAdjustment.create_object(
  :adjustment_date  => DateTime.now , 
  :description      => "awesome adjustment ",
  :warehouse_id => Warehouse.first.id 
)

item_array.each do |item|
  StockAdjustmentDetail.create_object(
    :stock_adjustment_id => stock_adjustment.id , 
    :quantity => 50, 
    :item_id => item.id 
  )
end

stock_adjustment.confirm_object(:confirmed_at => DateTime.now )

SalesOrder.where(:is_confirmed => true ).each do |po|
  DeliveryOrder.create_object(
    :delivery_date             => DateTime.now - 4.days         ,
    :description      => "description sales_delivery #{po.id}"      ,
    :sales_order_id => po.id,
    :warehouse_id => Warehouse.first.id 
  )
end

puts "Total DO: #{DeliveryOrder.count}" 

DeliveryOrder.all.each do |d_o|
  d_o.sales_order.sales_order_details.each do |sod|
    DeliveryOrderDetail.create_object(
      :sales_order_detail_id => sod.id ,
      :quantity => sod.quantity - 1 , 
      :delivery_order_id => d_o.id 
    )
  end
end

puts "Total d_o detail: #{DeliveryOrderDetail.count}"

AssetDetail.all.each do |asset_detail|
  
  
  asset_detail.assign_initial_item(
    :initial_item_id => asset_detail.component.items.first .id 
  )
end

Asset.all.each do |asset|
  Maintenance.create_object(
    :asset_id       => asset.id , 
    :complaint_date => DateTime.now , 
    :complaint      => "aesome",
    :complaint_case => MAINTENANCE_CASE[:emergency],
    :warehouse_id   => Warehouse.first.id 
  )
end

puts "Total maintenance #{Maintenance.count}"
