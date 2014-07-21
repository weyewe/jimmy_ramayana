Ext.define('AM.view.operation.StockAdjustment', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.stockadjustmentProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
			{
					xtype : 'stockadjustmentlist',
					flex : 2
				},
				
				{
					xtype : 'stockadjustmentdetaillist',
					flex : 2
				}, 
		]
});