require 'spec_helper'

describe Item do
  before(:each) do
    @item = Item.create_object(
      :sku => "34242wafaw",
      :description => "awesome item"
    )
  end
  
  it "should create unique SKU" do
    @item.should be_valid 
    
  end
end
