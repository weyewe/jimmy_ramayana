
json.success true 
json.total @total
json.maintenances @objects do |object|
 
	json.id              object.id              
  json.asset_id       object.asset_id
  json.asset_code   object.asset.code 
	json.code 						object.code 
  json.complaint_date  format_date_friendly( object.complaint_date )

  json.complaint    					object.complaint 
  json.complaint_case   			object.complaint_case

 
	
	if object.complaint_case == MAINTENANCE_CASE[:scheduled]
		json.complaint_case_text   	"Scheduled"
	elsif object.complaint_case == MAINTENANCE_CASE[:emergency]
		json.complaint_case_text   	"Emergency"
	end
	
  json.is_confirmed    				object.is_confirmed
	json.confirmed_at    format_date_friendly( object.confirmed_at ) 
	
	json.is_deleted    				object.is_deleted
	
	json.warehouse_id     object.warehouse_id
	json.warehouse_name		object.warehouse.name 

	 




	
end


