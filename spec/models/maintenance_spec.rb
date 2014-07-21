require 'spec_helper'

describe Maintenance do
  before(:each) do
    @warehouse = Warehouse.create_object(
      :name => "warehouse awesome",
      :description => "Badaboom"
    )
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
    
    @asset = Asset.create_object(
      :machine_id  => @machine.id, 
      :contact_id => @contact.id,
      :description =>  "Awesome asset",
      :code        =>  "382yuekljwf"
    )
    
    @asset_detail = @asset.asset_details.first 
    
    @stock_adjustment = StockAdjustment.create_object(
      :adjustment_date  => DateTime.now , 
      :description      => "awesome adjustment ",
      :warehouse_id => @warehouse.id 
    )
    
    @quantity1 = 5
    @soe = StockAdjustmentDetail.create_object(
      :stock_adjustment_id => @stock_adjustment.id , 
      :quantity => @quantity1, 
      :item_id => @item1.id 
    )
    
    @stock_adjustment.confirm_object(
      :confirmed_at => DateTime.now + 2.days
    )
    
  end 
  
  it "should not create maintenance if there is uninitialized asset_detail" do
    maintenance = Maintenance.create_object(
      :asset_id       => @asset.id ,
      :complaint_date => DateTime.now , 
      :complaint      => "This is broken!! fuuuck! ",
      :complaint_case => MAINTENANCE_CASE[:emergency],
      :warehouse_id => @warehouse.id
    )
    
    maintenance.errors.size.should_not == 0 
  end
  
  it "should create maintenance if all asset detail is initialized" do
    @asset_detail.assign_initial_item(
      :initial_item_id => @item1.id 
    )
    
    maintenance = Maintenance.create_object(
      :asset_id       => @asset.id ,
      :complaint_date => DateTime.now , 
      :complaint      => "This is broken!! fuuuck! ",
      :complaint_case => MAINTENANCE_CASE[:emergency],
      :warehouse_id => @warehouse.id
    )
    
    maintenance.errors.size.should == 0
    maintenance.should be_valid 
    
  end
  
  
  context "creating maintenance" do
    before(:each) do
      @asset_detail.assign_initial_item(
        :initial_item_id => @item1.id 
      )

      @maintenance = Maintenance.create_object(
        :asset_id       => @asset.id ,
        :complaint_date => DateTime.now , 
        :complaint      => "This is broken!! fuuuck! ",
        :complaint_case => MAINTENANCE_CASE[:emergency],
        :warehouse_id => @warehouse.id
      )
    end
    
    it "should create maintenacne details" do
      @maintenance.maintenance_details.count.should == @asset.asset_details.count 
    end
    
    context "assign replacement to maintenance detail" do
      before(:each) do
        @md1 = @maintenance.maintenance_details.first 
        @md1.update_maintenance_result(
          :diagnosis                  =>  "Rusak, butuh perbaikan",
          :diagnosis_case             =>  DIAGNOSIS_CASE[:require_fix], 
          :solution                   =>  "Diganti dengan awesome AAA",
          :solution_case              =>  SOLUTION_CASE[:solved], 
          
          :is_replacement_required    =>  true , 
          :replacement_item_id        =>  @item1.id 
        )
      end
      
      it "should result in valid md" do
        @md1.errors.messages.each {|x| puts "the message: #{x}"}
        @md1.errors.size.should == 0
        @md1.should be_valid 
      end
    end
  end
  
end
