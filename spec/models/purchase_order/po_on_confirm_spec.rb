require 'spec_helper'

describe PurchaseOrderDetail do
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
    
    @po_detail = PurchaseOrderDetail.create_object(
      :purchase_order_id  => @po.id       ,
      :item_id            => @item.id     ,
      :quantity           => @quantity    ,
      :discount           => @discount    ,
      :unit_price         => @unit_price
    )
  end
  
  it "should be confirmable" do
    @po.confirm_object(:confirmed_at => DateTime.now )
    
    @po.errors.size.should == 0 
    @po.should be_valid 
  end
  
  context "confirmed purchase order" do
    before(:each) do
      @item.reload
      @initial_item_pending_receival = @item.pending_receival
      @po.confirm_object(:confirmed_at => DateTime.now )
      @po.reload
      @po_detail.reload
      @item.reload 
    end
    
    it "should increase pending receival" do
      @final_item_pending_receival = @item.pending_receival
      
      diff = @final_item_pending_receival - @initial_item_pending_receival
      diff.should == @quantity 
      
    end
    
    it "should create a stock mutation" do
    
       
       stock_mutation_list = StockMutation.where(
        :item_id => @item.id,
        :source_document_detail_id => @po_detail.id , 
        :source_document_detail => @po_detail.class.to_s 
       )
       
       stock_mutation_list.count.should ==1  
       
       stock_mutation = stock_mutation_list.first 
       
       stock_mutation.case.should == STOCK_MUTATION_CASE[:addition]
       stock_mutation.item_case.should == STOCK_MUTATION_ITEM_CASE[:pending_receival]  
    end
    
  
    
    context "unconfirm purchase order" do
      before(:each) do
        @po.reload 
        @item.reload
        @po_detail.reload 
        @initial_item_pending_receival = @item.pending_receival
        @po.unconfirm_object 
        @po.reload 
        @item.reload
        @po_detail.reload
      end
      
      it "should deduct item.pending_receival" do
        @final_item_pending_receival = @item.pending_receival
        diff = @final_item_pending_receival - @initial_item_pending_receival
        diff.should == -1* @quantity
      end
      
      it "should destroy the stock mutation" do
        StockMutation.where(
          :item_id => @item.id,
          :source_document_detail_id => @po_detail.id , 
          :source_document_detail => @po_detail.class.to_s 
         ).count.should == 0 
      end
    end
    
    context "create stock_adjustment to make the unconfirm action fail" do
      before(:each) do
        @stock_adjustment = StockAdjustment.create_object(
          :adjustment_date  => DateTime.now , 
          :description      => "awesome adjustment "
        )
        
        @soe = StockAdjustmentDetail.create_object(
          :stock_adjustment_id => @stock_adjustment.id , 
          :quantity => -1*@quantity, 
          :item_id => @item.id 
        )
        
        @stock_adjustment.confirm_object(
          :confirmed_at => DateTime.now + 2.days
        )
        
        
        @po.reload 
        @item.reload
        @po_detail.reload
      end
      
      it "should not confirm stock_adjustment" do
        @stock_adjustment.errors.size.should_not == 0  
        
      end
    end
  
    context "create purchase receival to make the unconfirm action fail" do
      before(:each) do
        
        @pr = PurchaseReceival.create_object(
          :receival_date  => DateTime.new(2012,2,2,0,0,0),
          :description    => "Awesome purchase order",
          :purchase_order_id     => @po.id ,
          :warehouse_id => @warehouse.id 
        )
        
        @pr_detail = PurchaseReceivalDetail.create_object(
          :purchase_receival_id         => @pr.id       ,
          :purchase_order_detail_id     => @po_detail.id     ,
          :quantity                     => @quantity
        )
        
        @pr.confirm_object(:confirmed_at => DateTime.now)
        @po_detail.reload
        @po.reload 
      end
      
      it "should confirm pr" do
        @pr.errors.size.should ==0  
        @pr.is_confirmed.should be_true 
      end
      
      it "should not allow unconfirm in po_detail" do
        @po_detail.unconfirmable?.should be_false 
      end
      
      it "should not allow unconfirm in po level" do
        @po.unconfirm_object
        @po.is_confirmed.should be_true 
        @po.errors.size.should_not == 0 
      end
    end
  end
   

  
  
end
