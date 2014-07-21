
json.success true 
json.total @total
json.machines @objects do |object|
	json.id 								object.id  
 
	 
	json.name	object.name
	json.description	object.description 
	json.brand object.brand 
	
end


