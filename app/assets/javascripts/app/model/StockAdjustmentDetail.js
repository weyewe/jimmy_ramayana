Ext.define('AM.model.StockAdjustmentDetail', {
  	extend: 'Ext.data.Model',
  	fields: [
 

    	{ name: 'id', type: 'int' },
			{ name: 'stock_adjustment_id', type: 'int' },
			{ name: 'item_id', type: 'int' },
			{ name: 'item_sku', type: 'string' },
			
			{ name: 'quantity', type: 'int' },


			{ name: 'is_confirmed', type: 'boolean' },  
			{ name: 'confirmed_at', type: 'string' } 
			
			 

  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/stock_adjustment_details',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'stock_adjustment_details',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { stock_adjustment_detail : record.data };
				}
			}
		}
	
  
});
