require 'spec_helper'

describe SalesOrder do
  before(:each) do
    sku = "acedin3321"
    description = "awesome"
    standard_price = BigDecimal("80000")
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
    
    
  end
   
  it "should create valid item and contact" do
    @item.should be_valid
    @contact.should be_valid
  end
  


  it "should create valid stock adjustment" do
    @so = SalesOrder.create_object(
      :sales_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome sales order",
      :contact_id     => @contact.id 
    )
    
    @so.should be_valid 
  end
  
  it "should require sales_date and contact" do
    @so = SalesOrder.create_object(
      :sales_date  => nil, 
      :description    => "Awesome sales order",
      :contact_id     => @contact.id
    )
    
    @so.should_not be_valid 
    
    @so = SalesOrder.create_object(
      :sales_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome sales order",
      :contact_id     => nil 
    )
    
    @so.should_not be_valid
  end
  
  context "created sales_order => update" do
    before(:each) do
      @so = SalesOrder.create_object(
        :sales_date  => DateTime.new(2012,2,2,0,0,0),
        :description    => "Awesome sales order",
        :contact_id     => @contact.id 
      )
    end
    
    it "should  be updatable" do
      @so.update_object(
        :sales_date  => DateTime.new(2012,2,2,0,0,0),
        :description    => "Awesome sales order",
        :contact_id     => @contact.id
      )
      
      @so.errors.size.should == 0 
    end
    
    it "should be deletable" do
      @so.delete_object
      @so.persisted?.should be_false 
    end
    
    
  end
   
   
  
  
  
end
