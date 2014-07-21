require 'spec_helper'

describe Asset do
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
    
    
    @compa1 = Compatibility.create_object(
      :component_id => @component.id,
      :item_id => @item1.id 
    )
    
    
    @contact = Contact.create_object(
      :name     => "Awesome Custom",
      :address  => "address",
      :pic      => "andi sitorus",
      :contact  => "9348820423",
      :email    => "andi.sitorus@gmail.com"
    )
    
  end 
  
  context "machine is not initialized" do
    before(:each) do
      @machine2 = Machine.create_object(
        :name => "34242ahahawafaw",
        :brand => "Yokokahahao",
        :description => "awesome machine"
      )
    end
    
    it "should create machine" do
      @machine2.should be_valid 
    end
    
    it "should not allow asset creation" do
      asset = Asset.create_object(
        :machine_id  => @machine2.id, 
        :contact_id => @contact.id,
        :description =>  "Awesome aasset",
        :code        =>  "382yuekljaaawf"
      )
      
      asset.should_not be_valid
      asset.errors.size.should_not == 0 
    end
  end
  
  it "should be allowed to create asset" do
    asset = Asset.create_object(
      :machine_id  => @machine.id, 
      :contact_id => @contact.id,
      :description =>  "Awesome asset",
      :code        =>  "382yuekljwf"
    )
    
    asset.should be_valid 
  end
  
  context "created asset" do
    before(:each) do
      @asset = Asset.create_object(
        :machine_id  => @machine.id, 
        :contact_id => @contact.id,
        :description =>  "Awesome asset",
        :code        =>  "382yuekljwf"
      )
    end
    
    it "should automatically create part" do
      @asset.asset_details.count.should == 1 
      
      @asset.asset_details.first.component_id.should == @component.id 
    end
    
    
    context "adding initial item into the asset detail" do
      before(:each) do
        @asset_detail = @asset.asset_details.first 
      end
      
      it "should allow initial_item assignment" do
        @asset_detail.assign_initial_item(
          :initial_item_id => @item1.id 
        )
        
        @asset_detail.errors.size.should == 0 
        @asset_detail.initial_item_id.should == @item1.id
      end
      
      it "should not allow assignment of item not in the copatibility" do
        @asset_detail.assign_initial_item(
          :initial_item_id => @item2.id 
        )
        
        @asset_detail.errors.size.should_not == 0  
      end
    end
    
    context "adding new component to the machine" do
      before(:each) do
        @component2 = Component.create_object(
          :machine_id => @machine.id,
          :name => "name 1234 aaa",
          :description => "Awesome component extra"
        )
        
        @asset.reload 
      end
      
      it "should automatically create asset_part" do
        @asset.asset_details.count.should == 2 
        @asset.asset_details.order("id DESC").first.component_id.should == @component2.id 
      end
      
    end
  end
  
end
