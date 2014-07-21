Ext.define('AM.model.MaintenanceDetail', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
			{ name: 'maintenance_id', type: 'int' },
			{ name: 'maintenance_code', type: 'string' },
			{ name: 'component_id', type: 'int' },
			{ name: 'component_name', type: 'string' },
			
			{ name: 'diagnosis', type: 'string' },
			{ name: 'diagnosis_case', type: 'int' },
			{ name: 'diagnosis_case_text', type: 'string' },
			
			{ name: 'solution', type: 'string' },
			{ name: 'solution_case', type: 'int' },
			{ name: 'solution_case_text', type: 'string' },
			
			


			{ name: 'is_replacement_required', type: 'boolean' },  
			{ name: 'replacement_item_sku', type: 'string' } ,
			{ name: 'replacement_item_id', type: 'int' } 
			
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/maintenance_details',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'maintenance_details',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { maintenance_detail : record.data };
				}
			}
		}
	
  
});
