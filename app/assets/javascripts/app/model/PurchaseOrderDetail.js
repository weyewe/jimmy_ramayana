Ext.define('AM.model.PurchaseOrderDetail', {
  	extend: 'Ext.data.Model',
  	fields: [
 

    	{ name: 'id', type: 'int' },
			{ name: 'purchase_order_id', type: 'int' },
			{ name: 'item_id', type: 'int' },
			{ name: 'item_sku', type: 'string' },
			
			{ name: 'quantity', type: 'int' },


			{ name: 'is_confirmed', type: 'boolean' },  
			{ name: 'confirmed_at', type: 'string' } 
			
			 

  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/purchase_order_details',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'purchase_order_details',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { purchase_order_detail : record.data };
				}
			}
		}
	
  
});
