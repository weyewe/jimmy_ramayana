Ext.define('AM.model.Asset', {
  	extend: 'Ext.data.Model',
  	fields: [
 			

    	{ name: 'id', type: 'int' },
			{ name: 'machine_id', type: 'int' },
			{ name: 'contact_id', type: 'int' },
			{ name: 'machine_name', type: 'string' },
			
    	{ name: 'contact_name', type: 'string' } ,
			{ name: 'description', type: 'string' }, 
			{ name: 'code', type: 'string' } 
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/assets',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'assets',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { asset : record.data };
				}
			}
		}
	
  
});
