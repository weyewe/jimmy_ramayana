
json.success true 
json.total @total
json.records @objects do |object|

	json.id 								object.id  
	

 
	 
	json.machine_name		object.machine.name 
	json.code		object.code 
	
	json.contact_name				object.contact.name 
	
end


