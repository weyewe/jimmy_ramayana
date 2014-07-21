
json.success true 
json.total @total
json.purchase_receivals @objects do |object|
 
 
	
	json.id              		object.id             
  json.purchase_order_id 	object.purchase_order_id
  json.receival_date 			format_date_friendly( object.receival_date )  
  json.warehouse_id    		object.warehouse_id   
  json.warehouse_name  		object.warehouse.name  
  json.is_confirmed    		object.is_confirmed     
  json.is_deleted      		object.is_deleted      
  json.description     		object.description            
  json.confirmed_at    		format_date_friendly( object.confirmed_at )
	
end


