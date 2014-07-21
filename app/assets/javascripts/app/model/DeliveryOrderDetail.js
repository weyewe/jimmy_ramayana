Ext.define('AM.model.DeliveryOrderDetail', {
  	extend: 'Ext.data.Model',
  	fields: [ 

    	{ name: 'id', type: 'int' },
			{ name: 'delivery_order_id', type: 'int' },
			{ name: 'sales_order_detail_id', type: 'int' },
			{ name: 'item_id', type: 'int' },
			{ name: 'item_sku', type: 'string' },
			
			{ name: 'quantity', type: 'int' },


			
			 

  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/delivery_order_details',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'delivery_order_details',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { delivery_order_detail : record.data };
				}
			}
		}
	
  
});
