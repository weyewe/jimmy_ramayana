
json.success true 
json.total @total
json.purchase_order_details @objects do |object|
	json.id 								object.id  
	json.purchase_order_id											object.purchase_order_id
	json.item_id											object.item_id 
	json.item_sku											object.item.sku
							  
	json.quantity              object.quantity      
	json.pending_receival      object.pending_receival 
	json.is_confirmed         object.is_confirmed 
	json.confirmed_at                   format_date_friendly( object.confirmed_at )    
end


