Ext.define('AM.model.Compatibility', {
  	extend: 'Ext.data.Model',
  	fields: [
 

    	{ name: 'id', type: 'int' },
			{ name: 'item_id', type: 'int' },
			{ name: 'item_sku', type: 'string' },
			{ name: 'component_id', type: 'int' },
			{ name: 'component_name', type: 'string' },
			 
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/compatibilities',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'compatibilities',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { compatibility : record.data };
				}
			}
		}
	
  
});
