require 'spec_helper'

describe PurchaseReceivalDetail do
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
    
    @po = PurchaseOrder.create_object(
      :purchase_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :contact_id     => @contact.id 
    )
    
    @quantity = 3
    @quantity2 = 5
    @unit_price = BigDecimal("1500")
    @discount = BigDecimal("5")
    @po_detail = PurchaseOrderDetail.create_object(
          :purchase_order_id  => @po.id       ,
          :item_id            => @item.id     ,
          :quantity           => @quantity    ,
          :discount           => @discount    ,
          :unit_price         => @unit_price
        )
    
    @po_detail_2 = PurchaseOrderDetail.create_object(
          :purchase_order_id  => @po.id       ,
          :item_id            => @item2.id     ,
          :quantity           => @quantity2    ,
          :discount           => @discount    ,
          :unit_price         => @unit_price
        )
        
    @po.confirm_object(
      :confirmed_at => DateTime.now 
    )
    @po_detail.reload
    @po.reload
    @item.reload 
    
    @pr = PurchaseReceival.create_object(
      :receival_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :purchase_order_id     => @po.id , 
      :warehouse_id => @warehouse.id
    )
    @received_quantity = 1 
    @pr_detail = PurchaseReceivalDetail.create_object(
      :purchase_receival_id         => @pr.id       ,
      :purchase_order_detail_id     => @po_detail.id     ,
      :quantity                     => @received_quantity   
    )
    
  end
  
  it "should increase the pending receival" do
    @po_detail.pending_receival.should_not == 0 
    @po_detail.pending_receival.should == @po_detail.quantity
  end
  
  
  it "should allow PR to be confirmed" do
    @pr.confirm_object( {
      :confirmed_at => DateTime.now 
    } )
    
    @pr.is_confirmed?.should be_true 
  end
  
  
  
  context "post pr confirmation" do
    before(:each) do
      @po_detail.reload 
      @initial_pending_receival = @po_detail.pending_receival
      @pr.confirm_object( {
        :confirmed_at => DateTime.now 
      } )
      
      @pr.reload
      @po.reload
      @po_detail.reload 
      @item.reload 
    end
    
    it "should reduce pending receival by quantity" do
      @final_pending_receival = @po_detail.pending_receival
      
      diff = @initial_pending_receival - @final_pending_receival
      diff.should == @received_quantity
    end
  end
  
  
  
end
