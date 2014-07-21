Ext.define('AM.model.Maintenance', {
  	extend: 'Ext.data.Model',
  	fields: [

		 
		
		
    	{ name: 'id', type: 'int' },
			{ name: 'code', type: 'string' },
			{ name: 'asset_code', type: 'string' },
			{ name: 'asset_id', type: 'int' },
			
			{ name: 'machine_name', type: 'string' },
			{ name: 'machine_id', type: 'int' },
			
			
			
			{ name: 'warehouse_name', type: 'string' },
			{ name: 'warehouse_id', type: 'int' },
			
			{ name: 'complaint_case', type: 'int' },
			{ name: 'complaint_case_text', type: 'string' },
			
    	{ name: 'complaint_date', type: 'string' } ,
			{ name: 'complaint', type: 'string' } ,
			 
			
			{ name: 'is_confirmed', type: 'boolean' } ,
			{ name: 'confirmed_at', type: 'string' } ,

			{ name: 'is_deleted', type: 'boolean' } 
			
		
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/maintenances',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'maintenances',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { maintenance : record.data };
				}
			}
		}
	
  
});
