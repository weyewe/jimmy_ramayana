require 'spec_helper'

describe DeliveryOrderDetail do
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
    
    @item2 = Item.create_object(
    :sku            => sku + "awesome",
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
      :description    => "Awesome purchase order",
      :contact_id     => @contact.id 
    )
    
    @quantity = 3
    @quantity2 = 5
    @unit_price = BigDecimal("1500")
    @discount = BigDecimal("5")
    @so_detail = SalesOrderDetail.create_object(
          :sales_order_id  => @so.id       ,
          :item_id            => @item.id     ,
          :quantity           => @quantity    ,
          :discount           => @discount    ,
          :unit_price         => @unit_price
        )
    
    @so_detail_2 = SalesOrderDetail.create_object(
          :sales_order_id  => @so.id       ,
          :item_id            => @item2.id     ,
          :quantity           => @quantity2    ,
          :discount           => @discount    ,
          :unit_price         => @unit_price
        )
        
    @so.confirm_object(
      :confirmed_at => DateTime.now 
    )
    @so_detail.reload
    @so.reload
    @item.reload 

    @stock_adjustment = StockAdjustment.create_object(
    :adjustment_date  => DateTime.now , 
    :description      => "awesome adjustment ",
    :warehouse_id => @warehouse.id
    )

    @soe_quantity = 50
    @soe = StockAdjustmentDetail.create_object(
    :stock_adjustment_id => @stock_adjustment.id , 
    :quantity => @soe_quantity, 
    :item_id => @item2.id 
    )
    
    @soe2 = StockAdjustmentDetail.create_object(
    :stock_adjustment_id => @stock_adjustment.id , 
    :quantity => @soe_quantity, 
    :item_id => @item.id 
    )

    @stock_adjustment.confirm_object(:confirmed_at => DateTime.now - 2.days )

    @warehouse_item = WarehouseItem.where(
    :item_id => @item.id,
    :warehouse_id => @warehouse.id 
    ).first 
    
    @do = DeliveryOrder.create_object(
      :delivery_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :sales_order_id     => @so.id ,
      :warehouse_id => @warehouse.id
    )
  end
  
  
  it "should allow purchase receival detail creation" do

    @delivered_quantity = 1 
    @do_detail = DeliveryOrderDetail.create_object(
      :delivery_order_id         => @do.id       ,
      :sales_order_detail_id     => @so_detail.id     ,
      :quantity                     => @delivered_quantity   
    )
    
    @do_detail.should be_valid 
  end
  
  it "should not allow pr_detail if quantity > po_d.pending_delivery " do
    @do_detail = DeliveryOrderDetail.create_object(
      :delivery_order_id         => @do.id       ,
      :sales_order_detail_id     => @so_detail.id      ,
      :quantity                     => @so_detail.pending_delivery + 1 
    )
    
    @do_detail.errors.size.should_not == 0 
    @do_detail.should_not be_valid
  end
  
  context "created po_detail" do
    before(:each) do
      @delivered_quantity = 1 
    
      
      @do_detail = DeliveryOrderDetail.create_object(
        :delivery_order_id         => @do.id       ,
        :sales_order_detail_id     => @so_detail.id     ,
        :quantity                     => @delivered_quantity
      )
    end
    
    it "should be updatable" do
      @do_detail.update_object(
        :delivery_order_id         => @do.id       ,
        :sales_order_detail_id     => @so_detail.id     ,
        :quantity                     => @delivered_quantity + 1 
      )
      
      @do_detail.errors.size.should == 0
      @do_detail.should be_valid 
    end
    
    
    it "should not be updatable if total quantity is negative" do
      @do_detail.update_object(
        :delivery_order_id         => @do.id       ,
        :sales_order_detail_id     => @so_detail.id     ,
        :quantity                     => -1
      )
      
      @do_detail.errors.size.should_not == 0
      @do_detail.should_not be_valid
    end
    
    it "should be deletable" do
      @do_detail.delete_object
      @do_detail.persisted?.should be_false
    end
    
    it "should not allow double item receival" do
      @do_detail_2 = DeliveryOrderDetail.create_object(
        :delivery_order_id         => @do.id       ,
        :sales_order_detail_id     => @so_detail.id     ,
        :quantity                     => @quantity
      )
      
      @do_detail_2.errors.size.should_not == 0  
    end
    
    context "created 2 purchase receival detail" do
      before(:each) do
        @delivered_quantity_2 = 1 
        @do_detail_2 = DeliveryOrderDetail.create_object(
          :delivery_order_id         => @do.id       ,
          :sales_order_detail_id     => @so_detail_2.id     ,
          :quantity                     => @delivered_quantity_2
        )
      end 
      
      it "should create pr_detail_2" do
        @do_detail_2.errors.size.should == 0 
        @do_detail_2.should be_valid
      end
      
      it "should not allow update that results in non-unique PR " do
        @do_detail_2 = DeliveryOrderDetail.create_object(
          :delivery_order_id         => @do.id       ,
          :sales_order_detail_id     => @so_detail.id     ,
          :quantity                     => @delivered_quantity_2
        )
        
        @do_detail_2.errors.size.should_not ==0 
      
      end
      
      it "should  allwo self update " do
        @do_detail_2.update_object(
          :delivery_order_id         => @do.id       ,
          :sales_order_detail_id     => @so_detail_2.id     ,
          :quantity                     => @delivered_quantity_2 + 1
        )
        
        @do_detail_2.errors.messages.each {|x| puts "Error: #{x}"}
        @do_detail_2.errors.size.should == 0 
      
      end
    end
  end
end
