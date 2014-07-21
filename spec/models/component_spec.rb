require 'spec_helper'

describe Component do
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
  
  context "creating component" do
    before(:each) do
      @component = Component.create_object(
        :machine_id => @machine.id,
        :name => "name 1234",
        :description => "Awesome component"
      )
    end
    
    it "should create component" do 
      @component.should be_valid
    end
  end
end
