Ext.define('AM.view.operation.PurchaseReceival', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.purchasereceivalProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
			{
					xtype : 'purchasereceivallist',
					flex : 2
				},
				
				{
					xtype : 'purchasereceivaldetaillist',
					flex : 2
				}, 
		]
});