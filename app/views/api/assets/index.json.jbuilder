
json.success true 
json.total @total
json.assets @objects do |object|
	json.id 								object.id  
	

 	
	 
	json.contact_id		object.contact_id 
	json.contact_name		object.contact.name 
	
	json.machine_id				object.machine_id
	json.machine_name			object.machine.name
	
	json.code 								object.code
	json.description 					object.description

	
end


