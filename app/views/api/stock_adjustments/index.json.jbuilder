
json.success true 
json.total @total
json.stock_adjustments @objects do |object|
 

	json.id 								object.id  
	json.warehouse_id											object.warehouse_id
	json.warehouse_name											object.warehouse.name 
							  
	json.is_confirmed              object.is_confirmed      
	json.is_deleted         object.is_deleted 
	json.description                    object.description            
	json.adjustment_date 	      format_date_friendly( object.adjustment_date )    
	json.confirmed_at 	     format_date_friendly(object.confirmed_at )
	
end


