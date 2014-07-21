Ext.define('AM.model.AssetDetail', {
  	extend: 'Ext.data.Model',
  	fields: [
 			

    	{ name: 'id', type: 'int' },
			{ name: 'asset_id', type: 'int' },
			{ name: 'asset_code', type: 'string' },
			
			{ name: 'component_id', type: 'int' },
			{ name: 'component_name', type: 'string' },
			
			{ name: 'current_item_id', type: 'int' },
			{ name: 'current_item_sku', type: 'string' },
			{ name: 'initial_item_id', type: 'string' },
			{ name: 'initial_item_sku', type: 'string' },
			
    	{ name: 'maintenance_detail_id', type: 'string' } , 
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/asset_details',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'asset_details',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { asset_detail : record.data };
				}
			}
		}
	
  
});
