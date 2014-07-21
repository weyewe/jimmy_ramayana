Ext.define('AM.view.master.Compatibility', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.compatibilityProcess',
	 
		layout : {
			type : 'hbox',
			align : 'stretch'
		},
		header: false, 
		headerAsText : false,
		selectedParentId : null,
		
		items : [
		// list of compatibility loan.. just the list.. no CRUD etc
			{
				xtype : 'mastermachinecomponentList',
				flex : 1
			},
			
			{
				xtype : 'compatibilitylist',
				flex : 2
			}, 
		]
});