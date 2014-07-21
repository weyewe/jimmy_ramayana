Ext.define('AM.model.Item', {
  	extend: 'Ext.data.Model',
  	fields: [
 

    	{ name: 'id', type: 'int' },
			{ name: 'pending_receival', type: 'int' },
			{ name: 'ready', type: 'int' },
			{ name: 'pending_delivery', type: 'int' },
			
    	{ name: 'sku', type: 'string' } ,
			{ name: 'description', type: 'string' } ,
			
			{ name: 'item_type_id', type: 'int' } ,
			{ name: 'item_type_name', type: 'string' } ,
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/items',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'items',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { item : record.data };
				}
			}
		}
	
  
});
