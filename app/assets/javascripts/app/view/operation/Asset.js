Ext.define('AM.view.operation.Asset', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.assetProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
		// list of group loan.. just the list.. no CRUD etc
			{
				xtype : 'mastercontactList',
				flex : 1
			},
			
			{
				xtype : 'assetlist',
				flex : 2
			}, 
		]
});