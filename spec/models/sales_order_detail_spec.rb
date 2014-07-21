require 'spec_helper'

describe SalesOrderDetail do
  before(:each) do
    sku = "acedin3321"
    description = "awesome"
    standard_price = BigDecimal("80000")
    @item = Item.create_object(
    :sku            => sku,
    :description    => description, 
    :standard_price => standard_price
    )
    
    @item2 = Item.create_object(
    :sku            => sku + "32424",
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
    @discount = 0
    @unit_price  = BigDecimal("1500")
    
  end
   
  it "should allow purchase order detail creation" do
    @so_detail = SalesOrderDetail.create_object(
      :sales_order_id  => @so.id       ,
      :item_id            => @item.id     ,
      :quantity           => @quantity    ,
      :discount           => @discount    ,
      :unit_price         => @unit_price
    )
    
    @so_detail.should be_valid 
  end
  
  context "created po_detail" do
    before(:each) do
      @so_detail = SalesOrderDetail.create_object(
        :sales_order_id  => @so.id       ,
        :item_id            => @item.id     ,
        :quantity           => @quantity    ,
        :discount           => @discount    ,
        :unit_price         => @unit_price
      )
    end
    
    it "should be updatable" do
      @so_detail.update_object(
        :item_id => @item.id , 
        :quantity => 5, 
        :unit_price => BigDecimal("15000"),
        :discount => BigDecimal("5")
      )
      
      @so_detail.errors.messages.each {|x| puts "===========> #{x}"}
      @so_detail.errors.size.should == 0
      @so_detail.should be_valid 
    end
    
    
    it "should not be updatable if total quantity is negative" do
      @so_detail.update_object(
        :item_id => @item.id , 
        :quantity => -5, 
        :unit_price => BigDecimal("15000"),
        :discount => BigDecimal("5")
      )
      
      @so_detail.errors.size.should_not == 0
      @so_detail.should_not be_valid
    end
    
    it "should be deletable" do
      @so_detail.delete_object
      @so_detail.persisted?.should be_false
    end
    
    it "should not allow double item ordered" do
      @so_detail_2 = SalesOrderDetail.create_object(
        :sales_order_id  => @so.id       ,
        :item_id            => @item.id     ,
        :quantity           => @quantity   +3  ,
        :discount           => 0  ,
        :unit_price         => @unit_price
      )
      
      @so_detail_2.errors.size.should_not ==0  
    end
    
    context "created 2 po detail. update should still maintain uniqueness" do
      before(:each) do
        @so_detail_2 = SalesOrderDetail.create_object(
          :sales_order_id  => @so.id       ,
          :item_id            => @item2.id     ,
          :quantity           => @quantity   +3  ,
          :discount           => 0  ,
          :unit_price         => @unit_price
        )
      end
      
      it "should create po_detail_2" do
        @so_detail_2.errors.size.should == 0 
        @so_detail_2.should be_valid 
      end
      
      it "should preserve uniqueness on update" do
        @so_detail_2.update_object(
          :item_id => @item.id , 
          :quantity => @quantity, 
          :unit_price => BigDecimal("15000"),
          :discount => BigDecimal("5")
        )
        
        @so_detail_2.errors.size.should_not ==0 
        
        @so_detail_2.errors.messages.each {|x| puts "error: #{x}"}
      end
      
      it "should  allow self update" do
        @so_detail_2.update_object(
          :item_id => @item2.id , 
          :quantity => @quantity, 
          :unit_price => BigDecimal("150000"),
          :discount => BigDecimal("5")
        )
        
        @so_detail_2.errors.size.should ==0 
        
      end
    end
    
    
    
    
  end
  
  
  
end
