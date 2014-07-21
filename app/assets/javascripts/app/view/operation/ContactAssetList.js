Ext.define('AM.view.operation.ContactAssetList', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.operationcontactassetList',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
		// list of part loan.. just the list.. no CRUD etc
			{
				xtype : 'mastercontactList',
				flex : 1
			},
			
			{
				xtype : 'operationassetList',
				flex : 2
			}, 
		]
});