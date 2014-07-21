Ext.define('AM.model.Contact', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'name', type: 'string' },
			{ name: 'description', type: 'string' } 
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/contacts',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'contacts',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { contact : record.data };
				}
			}
		}
	
  
});
