
json.success true 
json.total @total
json.sales_order_details @objects do |object|
	json.id 								object.id  
	json.sales_order_id											object.sales_order_id
	json.item_id											object.item_id 
	json.item_sku											object.item.sku
							  
	json.quantity              object.quantity      
	json.pending_delivery      object.pending_delivery 
	json.is_confirmed         object.is_confirmed 
	json.confirmed_at                   format_date_friendly( object.confirmed_at )    
end


