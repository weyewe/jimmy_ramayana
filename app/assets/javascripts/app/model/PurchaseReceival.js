Ext.define('AM.model.PurchaseReceival', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'warehouse_id', type: 'int' },
			{ name: 'warehouse_name', type: 'string' },
			
			{ name: 'purchase_order_id', type: 'int' },


			{ name: 'is_confirmed', type: 'boolean' },
			{ name: 'is_deleted', type: 'boolean' },
			{ name: 'description', type: 'string' }, 
			{ name: 'receival_date', type: 'string' } ,
			{ name: 'confirmed_at', type: 'string' } 
		 
			 

  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/purchase_receivals',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'purchase_receivals',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { purchase_receival : record.data };
				}
			}
		}
	
  
});
