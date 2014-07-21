Ext.define('AM.view.operation.maintenancedetail.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.maintenancedetaillist',

  	store: 'MaintenanceDetails', 
 

	initComponent: function() {
		this.columns = [
			{	header: 'Component', dataIndex: 'component_name', flex: 1 }, 
			{
				xtype : 'templatecolumn',
				text : "Diagnosis",
				flex : 1,
				tpl : '<b>{diagnosis_case_text}</b>' + '<br />' + '<br />' +
							'<br /> {diagnosis}'  
			},
			
			{
				xtype : 'templatecolumn',
				text : "Solution",
				flex : 1,
				tpl : '<b>{solution_case_text}</b>' + '<br />' + '<br />' +
							'<br /> {solution}'  
			},
			
			{
				xtype : 'templatecolumn',
				text : "Replacement",
				flex : 1,
				tpl : 'Required: <b>{is_replacement_required}</b>' + '<br />' + '<br />' +
							'<br /> {replacement_item_sku}'  
			},
			
			
			
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add',
			action: 'addObject',
			disabled : true 
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete',
			action: 'deleteObject',
			disabled: true
		});
		this.updateResultObjectButton = new Ext.Button({
			text: 'Update Result',
			action: 'updateResultObject',
			disabled: true
		});
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});



		this.tbar = [ // this.addObjectButton, this.editObjectButton, this.deleteObjectButton,
		
		'->',
		this.updateResultObjectButton ];
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Displaying topics {0} - {1} of {2}',
			emptyMsg: "No topics to display" 
		});

		this.callParent(arguments);
	},
 
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},
	
	enableAddButton : function(){
		this.addObjectButton.enable();
	},
	
	disableAddButton : function(){
		this.addObjectButton.disable();
	},

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
		this.updateResultObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.updateResultObjectButton.disable();
	}
});
