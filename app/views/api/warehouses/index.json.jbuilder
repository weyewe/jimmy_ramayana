
json.success true 
json.total @total
json.warehouses @objects do |object|
	json.id 								object.id  
 
	 
	json.name	object.name
	json.description	object.description 
	
end


