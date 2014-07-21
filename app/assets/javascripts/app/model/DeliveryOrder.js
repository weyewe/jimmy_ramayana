Ext.define('AM.model.DeliveryOrder', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'warehouse_id', type: 'int' },
			{ name: 'warehouse_name', type: 'string' },
			
			{ name: 'sales_order_id', type: 'int' },


			{ name: 'is_confirmed', type: 'boolean' },
			{ name: 'is_deleted', type: 'boolean' },
			{ name: 'description', type: 'string' }, 
			{ name: 'delivery_date', type: 'string' } ,
			{ name: 'confirmed_at', type: 'string' } 
		 
			 

  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/delivery_orders',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'delivery_orders',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { delivery_order : record.data };
				}
			}
		}
	
  
});
