
json.success true 
json.total @total
json.delivery_orders @objects do |object|
 
 
	
	json.id              		object.id             
  json.sales_order_id 	object.sales_order_id
  json.delivery_date 			format_date_friendly( object.delivery_date )  
  json.warehouse_id    		object.warehouse_id   
  json.warehouse_name  		object.warehouse.name  
  json.is_confirmed    		object.is_confirmed     
  json.is_deleted      		object.is_deleted      
  json.description     		object.description            
  json.confirmed_at    		format_date_friendly( object.confirmed_at )
	
end


