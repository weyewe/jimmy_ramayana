Ext.define('AM.view.operation.PurchaseOrder', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.purchaseorderProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
			{
					xtype : 'purchaseorderlist',
					flex : 2
				},
				
				{
					xtype : 'purchaseorderdetaillist',
					flex : 2
				}, 
		]
});