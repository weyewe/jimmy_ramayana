Ext.define('AM.model.PurchaseReceivalDetail', {
  	extend: 'Ext.data.Model',
  	fields: [ 

    	{ name: 'id', type: 'int' },
			{ name: 'purchase_receival_id', type: 'int' },
			{ name: 'purchase_order_detail_id', type: 'int' },
			{ name: 'item_id', type: 'int' },
			{ name: 'item_sku', type: 'string' },
			
			{ name: 'quantity', type: 'int' },


			
			 

  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/purchase_receival_details',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'purchase_receival_details',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { purchase_receival_detail : record.data };
				}
			}
		}
	
  
});
