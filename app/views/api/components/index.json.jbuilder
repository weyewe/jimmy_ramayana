
json.success true 
json.total @total
json.components @objects do |object|
	json.id 								object.id  
 	json.machine_id 				object.machine.id
	json.machine_name				object.machine.name 
	 
	 
	json.name	object.name
	json.description	object.description  
	
end


