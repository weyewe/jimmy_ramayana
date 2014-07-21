
json.success true 
json.total @total
json.stock_adjustment_details @objects do |object|
	json.id 								object.id  
	json.stock_adjustment_id											object.stock_adjustment_id
	json.item_id											object.item_id 
	json.item_sku											object.item.sku
							  
	json.quantity              object.quantity      
	json.is_confirmed         object.is_confirmed 
	json.confirmed_at                   format_date_friendly( object.confirmed_at )    
end


