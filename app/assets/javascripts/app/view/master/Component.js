Ext.define('AM.view.master.Component', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.componentProcess',
	 
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
				xtype : 'mastermachineList',
				flex : 1
			},
			
			{
				xtype : 'componentlist',
				flex : 2
			}, 
		]
});