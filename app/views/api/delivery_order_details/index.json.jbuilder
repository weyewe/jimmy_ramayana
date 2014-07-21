
json.success true 
json.total @total
json.delivery_order_details @objects do |object| 
json.id		object.id
	json.delivery_order_id       object.delivery_order_id
  json.sales_order_detail_id   object.sales_order_detail_id
  json.item_id                    object.sales_order_detail.item.id
  json.item_sku                   object.sales_order_detail.item.sku
  json.quantity                   object.quantity


end


