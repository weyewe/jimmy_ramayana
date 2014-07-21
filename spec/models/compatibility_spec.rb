require 'spec_helper'

describe Compatibility do
  before(:each) do
    @machine = Machine.create_object(
      :name => "34242wafaw",
      :brand => "Yokoko",
      :description => "awesome machine"
    )
    @item1 = Item.create_object(
      :sku => "34242wafaw",
      :description => "awesome item"
    )
    
    @item2 = Item.create_object(
      :sku => "aa34242wafaw",
      :description => "awesome item2"
    )
    
    @component = Component.create_object(
      :machine_id => @machine.id,
      :name => "name 1234",
      :description => "Awesome component"
    )
    
    
  end 
  
  it "should be allowed to create compatibility" do
    @compa1 = Compatibility.create_object(
      :component_id => @component.id,
      :item_id => @item1.id 
    )
    
    @compa1.should be_valid 
  end
  
  context "creating compatibility" do
    before(:each) do
      @compa1 = Compatibility.create_object(
        :component_id => @component.id,
        :item_id => @item1.id 
      )
      
      @item1.reload
      @component.reload
    end
    
    it "should allow associations between component and item" do
      @component.items.count.should == 1 
      @item1.components.count.should == 1 
      @component.compatibilities.count.should == 1
      @item1.compatibilities.count.should == 1 
    end
  end
end
