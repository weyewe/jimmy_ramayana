Ext.define('AM.view.operation.Maintenance', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.maintenanceProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
			{
					xtype : 'maintenancelist',
					flex : 2
				},
				
				{
					xtype : 'maintenancedetaillist',
					flex : 2
				}, 
		]
});