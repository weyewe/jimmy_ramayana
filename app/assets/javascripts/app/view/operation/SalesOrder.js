Ext.define('AM.view.operation.SalesOrder', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.salesorderProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
			{
					xtype : 'salesorderlist',
					flex : 2
				},
				
				{
					xtype : 'salesorderdetaillist',
					flex : 2
				}, 
		]
});