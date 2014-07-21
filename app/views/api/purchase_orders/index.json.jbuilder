
json.success true 
json.total @total
json.purchase_orders @objects do |object|
 
	json.id              object.id              
  json.contact_id       object.contact_id
  json.contact_name   object.contact.name 
  json.purchase_date  format_date_friendly( object.purchase_date )
  json.description    object.description 
  json.is_confirmed   object.is_confirmed
  json.confirmed_at    format_date_friendly( object.confirmed_at )


	
end


