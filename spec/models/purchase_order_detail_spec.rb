require 'spec_helper'

describe PurchaseOrderDetail do
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
    
    @po = PurchaseOrder.create_object(
      :purchase_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :contact_id     => @contact.id 
    )
    
    @quantity = 3
    @discount = 0
    @unit_price  = BigDecimal("1500")
    
  end
   
  it "should allow purchase order detail creation" do
    @po_detail = PurchaseOrderDetail.create_object(
      :purchase_order_id  => @po.id       ,
      :item_id            => @item.id     ,
      :quantity           => @quantity    ,
      :discount           => @discount    ,
      :unit_price         => @unit_price
    )
    
    @po_detail.should be_valid 
  end
  
  context "created po_detail" do
    before(:each) do
      @po_detail = PurchaseOrderDetail.create_object(
        :purchase_order_id  => @po.id       ,
        :item_id            => @item.id     ,
        :quantity           => @quantity    ,
        :discount           => @discount    ,
        :unit_price         => @unit_price
      )
    end
    
    it "should be updatable" do
      @po_detail.update_object(
        :item_id => @item.id , 
        :quantity => 5, 
        :unit_price => BigDecimal("15000"),
        :discount => BigDecimal("5")
      )
      
      @po_detail.errors.messages.each {|x| puts "===========> #{x}"}
      @po_detail.errors.size.should == 0
      @po_detail.should be_valid 
    end
    
    
    it "should not be updatable if total quantity is negative" do
      @po_detail.update_object(
        :item_id => @item.id , 
        :quantity => -5, 
        :unit_price => BigDecimal("15000"),
        :discount => BigDecimal("5")
      )
      
      @po_detail.errors.size.should_not == 0
      @po_detail.should_not be_valid
    end
    
    it "should be deletable" do
      @po_detail.delete_object
      @po_detail.persisted?.should be_false
    end
    
    it "should not allow double item ordered" do
      @po_detail_2 = PurchaseOrderDetail.create_object(
        :purchase_order_id  => @po.id       ,
        :item_id            => @item.id     ,
        :quantity           => @quantity   +3  ,
        :discount           => 0  ,
        :unit_price         => @unit_price
      )
      
      @po_detail_2.errors.size.should_not ==0  
    end
    
    context "created 2 po detail. update should still maintain uniqueness" do
      before(:each) do
        @po_detail_2 = PurchaseOrderDetail.create_object(
          :purchase_order_id  => @po.id       ,
          :item_id            => @item2.id     ,
          :quantity           => @quantity   +3  ,
          :discount           => 0  ,
          :unit_price         => @unit_price
        )
      end
      
      it "should create po_detail_2" do
        @po_detail_2.errors.size.should == 0 
        @po_detail_2.should be_valid 
      end
      
      it "should preserve uniqueness on update" do
        @po_detail_2.update_object(
          :item_id => @item.id , 
          :quantity => @quantity, 
          :unit_price => BigDecimal("15000"),
          :discount => BigDecimal("5")
        )
        
        @po_detail_2.errors.size.should_not ==0 
        
        @po_detail_2.errors.messages.each {|x| puts "error: #{x}"}
      end
      
      it "should  allow self update" do
        @po_detail_2.update_object(
          :item_id => @item2.id , 
          :quantity => @quantity, 
          :unit_price => BigDecimal("150000"),
          :discount => BigDecimal("5")
        )
        
        @po_detail_2.errors.size.should ==0 
        
      end
    end
    
    
    
    
  end
  
  
  
end
