
json.success true 
json.total @total
json.compatibilities @objects do |object|
	json.id 								object.id  
	json.item_id											object.item_id						  
	json.item_sku              object.item.sku      
	json.component_id         object.component.id 
	json.component_name                    object.component.name
 
end


