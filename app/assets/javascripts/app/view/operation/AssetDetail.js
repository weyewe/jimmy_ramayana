Ext.define('AM.view.operation.AssetDetail', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.assetdetailProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
		// list of assetdetail loan.. just the list.. no CRUD etc
			{
				xtype : 'operationcontactassetList',
				flex : 1
			},
			
			{
				xtype : 'assetdetaillist',
				flex : 2
			}, 
		]
});