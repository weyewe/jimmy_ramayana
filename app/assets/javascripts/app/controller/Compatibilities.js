Ext.define('AM.controller.Compatibilities', {
  extend: 'Ext.app.Controller',

  stores: ['Machines', 'Components', 'Compatibilities'],
  models: ['Compatibility'],

	selectedParentId1: null, 
	selectedParentId2: null, 
	
  views: [
    'master.compatibility.List',
    'master.compatibility.Form',
		'master.Compatibility',
		'master.MachineComponentList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "compatibilityProcess"
		},
		{
			ref : 'parentList1',
			selector : 'compatibilityProcess mastermachinecomponentList mastermachineList'
		},
		
		{
			ref : 'parentList2',
			selector : 'compatibilityProcess mastermachinecomponentList mastercomponentList'
		},
		{
			ref: 'list',
			selector: 'compatibilitylist'
		},
		{
			ref : 'searchField1',
			selector: 'compatibilityProcess mastermachinecomponentList mastermachineList textfield[name=searchField]'
		},
		{
			ref : 'searchField2',
			selector: 'compatibilityProcess mastermachinecomponentList mastercomponentList textfield[name=searchField]'
		},
		{
			ref : 'searchField',
			selector: 'compatibilitylist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'compatibilityProcess mastermachinecomponentList mastermachineList' : {
				afterrender : this.loadParentObjectList1,
				selectionchange: this.parentSelectionChange1,
			},
			
			'compatibilityProcess mastermachinecomponentList mastercomponentList' : {
				selectionchange: this.parentSelectionChange2,
			},
	
      'compatibilitylist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				destroy : this.onDestroy
      },

      'compatibilityform button[action=save]': {
        click: this.updateObject
      },
      'compatibilitylist button[action=addObject]': {
        click: this.addObject
      },
      'compatibilitylist button[action=editObject]': {
        click: this.editObject
      },
      'compatibilitylist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'componentProcess compatibilitylist textfield[name=searchField]': {
        change: this.liveSearch
      },

    });
  },

	loadParentObjectList1 : function(me){
		var currentController = this; 
		
		var parentList1 = currentController.getParentList1();
		var parentList2 = currentController.getParentList2();
		var grid = currentController.getList();
		
		currentController.selectedParentId1 = null;
		currentController.selectedParentId2 = null;
		
		
		me.getStore().getProxy().extraParams =  {};
		me.getStore().load(); 
		
		grid.getStore().loadData([],false);
		parentList2.getStore().loadData([],false);
	},
	
	parentSelectionChange1 : function(selectionModel, selections) {
		var me = this; 
    var grid = me.getList();
		var parentList1 = me.getParentList1();
		var parentList2 = me.getParentList2();
		var wrapper = me.getWrapper();
		
		if (parentList1.getSelectionModel().hasSelection()) {
			var row = parentList1.getSelectionModel().getSelection()[0];
			var id = row.get("id"); 
			
			if( me.selectedParentId1 !==  id){
				me.selectedParentId1 = id; 
				// reload
				grid.getStore().loadData([],false);
				parentList2.getStore().getProxy().extraParams.parent_id =  id  ;
				parentList2.getStore().load();
				
				// disable all buttons on grid
				grid.disableRecordButtons();
				grid.disableAddButton();
			}
		}
  },

	parentSelectionChange2 : function(selectionModel, selections) {
		var me = this; 
    var grid = me.getList();
		var parentList1 = me.getParentList1();
		var parentList2 = me.getParentList2();
		var wrapper = me.getWrapper();
		
		if (parentList2.getSelectionModel().hasSelection()) {
			// reload 
			var row = parentList2.getSelectionModel().getSelection()[0];
			var id = row.get("id"); 
			
			if( me.selectedParentId2 !==  id){
				me.selectedParentId2 = id; 
				
				grid.getStore().getProxy().extraParams.parent_id =  id  ;
				grid.getStore().load();
			}
			
			// enable add button 
			grid.enableAddButton();
		}
  },
	
 

	onDestroy: function(){
		this.getCompatibilitiesStore().loadData([],false);
	},

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getCompatibilitiesStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getMachinesStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	

  addObject: function() {
	
    
		var parentObject1  = this.getParentList1().getSelectedObject();
		var parentObject2  = this.getParentList2().getSelectedObject();
		
		if( parentObject1 && parentObject2 ) {
			var view = Ext.widget('compatibilityform');
			
			view.show();
			
			view.setParentData1(parentObject1);
			view.setParentData2(parentObject2);
		}
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
		var parentObject1  = this.getParentList1().getSelectedObject();
		var parentObject2  = this.getParentList1().getSelectedObject();
		
		if( record ) {
			var view = Ext.widget('compatibilityform');
			view.show();
			view.setParentData1(parentObject1);
			view.setParentData2(parentObject2);
			view.setComboBoxData( record );
		}
		
		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList1 = this.getParentList1();
		var wrapper = this.getWrapper();

    var store = this.getCompatibilitiesStore();
    var record = form.getRecord();
    var values = form.getValues();

		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					
					store.load({
						params: {
							parent_id : me.selectedParentId2
						}
					});
					 
					
					win.close();
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.Compatibility( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load({
						params: {
							parent_id : me.selectedParentId2 
						}
					});
					
					form.setLoading(false);
					win.close();
					
				},
				failure: function( record, op){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
		} 
  },

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getCompatibilitiesStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
  
    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  },



	

});
