require 'spec_helper'

describe DeliveryOrder do
  before(:each) do
    sku = "acedin3321"
    description = "awesome"
    standard_price = BigDecimal("80000")
    @warehouse = Warehouse.create_object(
      :name => "warehouse awesome",
      :description => "Badaboom"
    )
    @item = Item.create_object(
    :sku            => sku,
    :description    => description, 
    :standard_price => standard_price
    )
    
    @contact = Contact.create_object(
      :name             => "Contact"           ,
      :description      => "Description"      ,
      :address          =>  "Address"        ,
      :shipping_address => "Shipping Address"
    )
    
    @so = SalesOrder.create_object(
      :sales_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome delivery order",
      :contact_id     => @contact.id 
    )
    
    @quantity = 3
    @unit_price = BigDecimal("1500")
    @discount = BigDecimal("5")
    @so_detail = SalesOrderDetail.create_object(
          :sales_order_id  => @so.id       ,
          :item_id            => @item.id     ,
          :quantity           => @quantity    ,
          :discount           => @discount    ,
          :unit_price         => @unit_price
        )
        
    @so.confirm_object(
      :confirmed_at => DateTime.now 
    )
    @so_detail.reload
    @so.reload
    @item.reload 
  end
  
  it "should have pending receival item" do
    @item.pending_delivery.should == @quantity
  end
   
  


  it "should create valid delivery receival" do
    
     
    @do = DeliveryOrder.create_object(
      :delivery_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome delivery order",
      :sales_order_id     => @so.id ,
      :warehouse_id => @warehouse.id 
    )
    
    @do.should be_valid 
  end
  
  it "should require receival date and delivery order" do
    @do = DeliveryOrder.create_object(
      :delivery_date  => nil,
      :description    => "Awesome delivery order",
      :sales_order_id     => @so.id 
    )
    
    @do.should_not be_valid 
    
    @do = DeliveryOrder.create_object(
      :delivery_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome delivery order",
      :sales_order_id     =>  nil,
      :warehouse_id => @warehouse.id
    )
    
    @do.should_not be_valid
  end
  
  context "created delivery_order => update" do
    before(:each) do
      @do = DeliveryOrder.create_object(
        :delivery_date  => DateTime.new(2012,2,2,0,0,0),
        :description    => "Awesome delivery receival",
        :sales_order_id     => @so.id,
        :warehouse_id => @warehouse.id
      )
    end
    
    it "should  be updatable" do
      @do.update_object(
        :delivery_date  => DateTime.new(2012,2,2,0,0,0),
        :description    => "Awesome delivery rec",
        :sales_order_id     => @so.id,
        :warehouse_id => @warehouse.id
      )
      
      @do.errors.size.should == 0 
    end
    
    it "should be deletable" do
      @do.delete_object
      @do.persisted?.should be_false 
    end
    
    
  end
  
end
