
json.success true 
json.total @total
json.asset_details @objects do |object|
	json.id 								object.id  
	 
	 
	json.asset_id		object.asset_id 
	json.asset_code		object.asset.code 
	
	json.component_id				object.component_id
	json.component_name			object.component.name
	
	json.current_item_id 								object.current_item_id
	
	if not object.current_item_id.nil?
		json.current_item_sku 								object.current_item.sku
	else
		json.current_item_sku 								""
	end
	
	json.initial_item_id 								object.initial_item_id
	
	if not object.initial_item_id.nil?
		json.initial_item_sku 								object.initial_item.sku
	else
		json.initial_item_sku 								""
	end
	 
end


