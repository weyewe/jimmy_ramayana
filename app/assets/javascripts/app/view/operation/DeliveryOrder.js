Ext.define('AM.view.operation.DeliveryOrder', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.deliveryorderProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
			{
					xtype : 'deliveryorderlist',
					flex : 2
				},
				
				{
					xtype : 'deliveryorderdetaillist',
					flex : 2
				}, 
		]
});