require 'spec_helper'

describe Machine do
  before(:each) do
    @machine = Machine.create_object(
      :name => "34242wafaw",
      :brand => "Yokoko",
      :description => "awesome machine"
    )
  end
  
  it "should create  machine" do
    @machine.should be_valid 
    
  end
  
  context "delete machine post component creation " do
    before(:each) do
      @component = Component.create_object(
        :machine_id => @machine.id,
        :name => "name 1234",
        :description => "Awesome component"
      )
    end
    
    it "should not be allowed to delete machine" do
      @machine.delete_object
      
      @machine.persisted?.should be_true 
    end
  end
end
