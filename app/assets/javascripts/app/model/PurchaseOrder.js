Ext.define('AM.model.PurchaseOrder', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'contact_id', type: 'int' },
			{ name: 'contact_name', type: 'string' },


			{ name: 'is_confirmed', type: 'boolean' },
			{ name: 'is_deleted', type: 'boolean' },
			{ name: 'description', type: 'string' }, 
			{ name: 'purchase_date', type: 'string' } ,
			{ name: 'confirmed_at', type: 'string' } 
			
			 

  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/purchase_orders',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'purchase_orders',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { purchase_order : record.data };
				}
			}
		}
	
  
});
