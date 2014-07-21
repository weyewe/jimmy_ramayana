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
    @po.confirm_object(:confirmed_at => DateTime.now)
    

  end
  
  it "should confirm PO" do
    @po.is_confirmed.should be_true 
  end
  
  context "creating purchase receival" do
    before(:each) do
      @item.reload 
      @initial_pending_receival = @item.pending_receival
      @initial_ready = @item.ready
      
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
       @item.reload 
    end
    
    it "should reduce pending receival" do
      @final_pending_receival = @item.pending_receival
      diff = @final_pending_receival - @initial_pending_receival
      diff.should == -1 * @quantity 
    end
    
    it "should increase ready stock" do
      @final_ready = @item.ready
      diff = @final_ready - @initial_ready
      diff.should == 1 * @quantity
    end
    
    it "should create 2 stock mutations " do
      stock_mutation_list = StockMutation.where(
        :item_id => @item.id,
        :source_document_detail_id => @pr_detail.id , 
        :source_document_detail => @pr_detail.class.to_s 
       )
       
       stock_mutation_list.count.should == 2 
       
       pending_receival_stock_mutation = stock_mutation_list.where(:item_case => STOCK_MUTATION_ITEM_CASE[:pending_receival]  ).first
       ready_stock_mutation = stock_mutation_list.where(:item_case => STOCK_MUTATION_ITEM_CASE[:ready]  ).first
       pending_receival_stock_mutation.should be_valid
       ready_stock_mutation.should be_valid 
       
       pending_receival_stock_mutation.case.should == STOCK_MUTATION_CASE[:deduction]
       ready_stock_mutation.case.should == STOCK_MUTATION_CASE[:addition]
    end
    
    context "creating negative stock adjustment, so that pr can't be unconfirmed " do
      before(:each) do
        @po_detail.reload
        @po.reload
        @item.reload
        @pr.reload
        @initial_ready_item = @item.ready 

        @stock_adjustment = StockAdjustment.create_object(
          :adjustment_date  => DateTime.now , 
          :description      => "awesome adjustment ",
          :warehouse_id => @warehouse.id 
        )
        
        @soe = StockAdjustmentDetail.create_object(
          :stock_adjustment_id => @stock_adjustment.id , 
          :quantity => -1* @quantity, 
          :item_id => @item.id 
        )
        
        @stock_adjustment.confirm_object(:confirmed_at => DateTime.now)
        @po_detail.reload
        @po.reload
        @item.reload
        @pr.reload
        
        @pr_detail.reload 
      end
      
      it "should confirm stock adjustment" do
        @stock_adjustment.is_confirmed.should be_true 
      end
      
      it "should reduce ready item" do
        @final_ready_item = @item.ready 
        diff = @final_ready_item - @initial_ready_item
        diff.should == -1 * @quantity 
      end
      
      it "should not be unconfirmable" do
        @pr_detail.unconfirmable?.should be_false
      end
      
      it "should not allow confirm" do
        @pr.unconfirm_object
        @pr.errors.size.should_not == 0 
      end
      
      
    end
    
    
    context "unconfirm purchase receival" do
      before(:each) do
        @item.reload 
        @initial_pending_receival = @item.pending_receival
        @initial_ready = @item.ready

       
         @pr.unconfirm_object 
         @po_detail.reload
         @po.reload
         @item.reload
         @pr.reload 
      end
      
      it "should unconfirm the pr" do
        @pr.is_confirmed.should be_false 
      end
      
      it "should increase pending receival" do
        @final_pending_receival = @item.pending_receival
        diff = @final_pending_receival - @initial_pending_receival
        diff.should == 1 * @quantity
      end
      
      it "should decrease ready stock" do
        @final_ready = @item.ready
        diff = @final_ready - @initial_ready
        diff.should == -1*@quantity
      end
      
      it "should have no stock mutations " do
        StockMutation.where(
          :item_id => @item.id,
          :source_document_detail_id => @pr_detail.id , 
          :source_document_detail => @pr_detail.class.to_s 
         ).count.should ==0 
      end
    end
  
  
  end
  

  
  
end
