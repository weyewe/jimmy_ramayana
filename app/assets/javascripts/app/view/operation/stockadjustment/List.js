Ext.define('AM.view.operation.stockadjustment.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.stockadjustmentlist',

  	store: 'StockAdjustments', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'AdjustmentDate', dataIndex: 'adjustment_date'},
			{	header: 'Deskripsi', dataIndex: 'description', flex: 1 }, 
			{	header: 'Konfirmasi', dataIndex: 'is_confirmed', flex: 1 }, 
			{	header: 'Tanggal Konfirmasi', dataIndex: 'confirmed_at', flex: 1 }, 
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add ',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit ',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete ',
			action: 'deleteObject',
			disabled: true
		});
		
		this.confirmObjectButton = new Ext.Button({
			text: 'Confirm ',
			action: 'confirmObject',
			disabled: true
		});
		
		this.searchField = new Ext.form.field.Text({
			name: 'searchField',
			hideLabel: true,
			width: 200,
			emptyText : "Search",
			checkChangeBuffer: 300
		});


		this.unconfirmObjectButton = new Ext.Button({
			text: 'Unconfirm',
			action: 'unconfirmObject',
			disabled: true,
			hidden :true 
		});


		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton, 
		this.confirmObjectButton, 
		this.unconfirmObjectButton, 
		
		'->', 
		this.searchField ];
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

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		this.deleteObjectButton.enable();
		this.confirmObjectButton.enable();
		this.unconfirmObjectButton.enable();
		
		selectedObject = this.getSelectedObject();
		if( selectedObject && selectedObject.get("is_confirmed") == true ){
			this.confirmObjectButton.hide();
			this.unconfirmObjectButton.show();
		}else{
			this.confirmObjectButton.show();
			this.unconfirmObjectButton.hide();
			
		}
		
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.confirmObjectButton.disable();
		this.unconfirmObjectButton.disable();
	}
});
