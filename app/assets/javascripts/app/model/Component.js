Ext.define('AM.model.Component', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'machine_id', type: 'int' },
			{ name: 'machine_name', type: 'string' },
			{ name: 'name', type: 'string' }, 
			{ name: 'description', type: 'string' } 
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/components',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'components',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { component : record.data };
				}
			}
		}
	
  
});
