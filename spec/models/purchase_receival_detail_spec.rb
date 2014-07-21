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
  end
  
  
  it "should allow purchase receival detail creation" do

    @received_quantity = 1 
    @pr_detail = PurchaseReceivalDetail.create_object(
      :purchase_receival_id         => @pr.id       ,
      :purchase_order_detail_id     => @po_detail.id     ,
      :quantity                     => @received_quantity   
    )
    
    @pr_detail.should be_valid 
  end
  
  it "should not allow pr_detail if quantity > po_d.pending_receival " do
    @pr_detail = PurchaseReceivalDetail.create_object(
      :purchase_receival_id         => @pr.id       ,
      :purchase_order_detail_id     => @po_detail.id      ,
      :quantity                     => @po_detail.pending_receival + 1 
    )
    
    @pr_detail.errors.size.should_not == 0 
    @pr_detail.should_not be_valid
  end
  
  context "created pr_detail" do
    before(:each) do
      @received_quantity = 1 
    
      
      @pr_detail = PurchaseReceivalDetail.create_object(
        :purchase_receival_id         => @pr.id       ,
        :purchase_order_detail_id     => @po_detail.id     ,
        :quantity                     => @received_quantity
      )
    end
    
    it "should be updatable" do
      @pr_detail.update_object(
        :purchase_receival_id         => @pr.id       ,
        :purchase_order_detail_id     => @po_detail.id     ,
        :quantity                     => @received_quantity + 1 
      )
      
      @pr_detail.errors.size.should == 0
      @pr_detail.should be_valid 
    end
    
    
    it "should not be updatable if total quantity is negative" do
      @pr_detail.update_object(
        :purchase_receival_id         => @pr.id       ,
        :purchase_order_detail_id     => @po_detail.id     ,
        :quantity                     => -1
      )
      
      @pr_detail.errors.size.should_not == 0
      @pr_detail.should_not be_valid
    end
    
    it "should be deletable" do
      @pr_detail.delete_object
      @pr_detail.persisted?.should be_false
    end
    
    it "should not allow double item receival" do
      @pr_detail_2 = PurchaseReceivalDetail.create_object(
        :purchase_receival_id         => @pr.id       ,
        :purchase_order_detail_id     => @po_detail.id     ,
        :quantity                     => @quantity
      )
      
      @pr_detail_2.errors.size.should_not == 0  
    end
    
    context "created 2 purchase receival detail" do
      before(:each) do
        @received_quantity_2 = 1 
        @pr_detail_2 = PurchaseReceivalDetail.create_object(
          :purchase_receival_id         => @pr.id       ,
          :purchase_order_detail_id     => @po_detail_2.id     ,
          :quantity                     => @received_quantity_2
        )
      end 
      
      it "should create pr_detail_2" do
        @pr_detail_2.errors.size.should == 0 
        @pr_detail_2.should be_valid
      end
      
      it "should not allow update that results in non-unique PR " do
        @pr_detail_2 = PurchaseReceivalDetail.create_object(
          :purchase_receival_id         => @pr.id       ,
          :purchase_order_detail_id     => @po_detail.id     ,
          :quantity                     => @received_quantity_2
        )
        
        @pr_detail_2.errors.size.should_not ==0 
      
      end
      
      it "should  allwo self update " do
        @pr_detail_2.update_object(
          :purchase_receival_id         => @pr.id       ,
          :purchase_order_detail_id     => @po_detail_2.id     ,
          :quantity                     => @received_quantity_2 + 1
        )
        
        @pr_detail_2.errors.messages.each {|x| puts "Error: #{x}"}
        @pr_detail_2.errors.size.should == 0 
      
      end
    end
  end
end
