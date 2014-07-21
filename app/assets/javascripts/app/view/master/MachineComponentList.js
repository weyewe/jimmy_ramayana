Ext.define('AM.view.master.MachineComponentList', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.mastermachinecomponentList',
	 
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
				xtype : 'mastermachineList',
				flex : 1
			},
			
			{
				xtype : 'mastercomponentList',
				flex : 2
			}, 
		]
});