Ext.define('AM.controller.AssetDetails', {
  extend: 'Ext.app.Controller',

  stores: ['Assets', 'Contacts', 'AssetDetails'],
  models: ['AssetDetail'],

	selectedParentId1: null, 
	selectedParentId2: null, 
	
  views: [
    'operation.assetdetail.List',
    'operation.assetdetail.Form',
		'operation.AssetDetail',
		'operation.ContactAssetList'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "assetdetailProcess"
		},
		{
			ref : 'parentList1',
			selector : 'assetdetailProcess operationcontactassetList mastercontactList'
		},
		
		{
			ref : 'parentList2',
			selector : 'assetdetailProcess operationcontactassetList operationassetList'
		},
		{
			ref: 'list',
			selector: 'assetdetaillist'
		},
		{
			ref : 'searchField1',
			selector: 'assetdetailProcess operationcontactassetList mastercontactList textfield[name=searchField]'
		},
		{
			ref : 'searchField2',
			selector: 'assetdetailProcess operationcontactassetList operationassetList textfield[name=searchField]'
		},
		{
			ref : 'searchField',
			selector: 'assetdetaillist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'assetdetailProcess operationcontactassetList mastercontactList' : {
				afterrender : this.loadParentObjectList1,
				selectionchange: this.parentSelectionChange1,
			},
			
			'assetdetailProcess operationcontactassetList operationassetList' : {
				selectionchange: this.parentSelectionChange2,
			},
	
      'assetdetaillist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				destroy : this.onDestroy
      },

      'assetdetailform button[action=save]': {
        click: this.updateObject
      },
      'assetdetaillist button[action=addObject]': {
        click: this.addObject
      },

			'assetdetaillist button[action=assignObject]': {
        click: this.assignObject
      },

			'assetdetailassignform button[action=save]': {
        click: this.executeAssignObject
      },


      'assetdetaillist button[action=editObject]': {
        click: this.editObject
      },
      'assetdetaillist button[action=deleteObject]': {
        click: this.deleteObject
      },

    });
  },

	loadParentObjectList1 : function(me){
		console.log("nside load parent objct list 1");
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
		this.getAssetDetailsStore().loadData([],false);
	},

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getAssetDetailsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getProjectsStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	

  addObject: function() {
	
    
		var parentObject1  = this.getParentList1().getSelectedObject();
		var parentObject2  = this.getParentList2().getSelectedObject();
		
		if( parentObject1 && parentObject2 ) {
			var view = Ext.widget('assetdetailform');
			
			view.show();
			
			view.setParentData1(parentObject1);
			view.setParentData2(parentObject2);
			view.setExtraParamForJsonRemoteStore( parentObject2.get("machine_id"));
		}
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();
		var parentObject1  = this.getParentList1().getSelectedObject();
		var parentObject2  = this.getParentList1().getSelectedObject();
		
		if( record ) {
			var view = Ext.widget('assetdetailform');
			view.show();
			view.setParentData1(parentObject1);
			view.setParentData2(parentObject2);
		}
		
		

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList1 = this.getParentList1();
		var wrapper = this.getWrapper();

    var store = this.getAssetDetailsStore();
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
			var newObject = new AM.model.AssetDetail( values ) ;
			
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
      var store = this.getAssetDetailsStore();
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

	reloadRecord: function(record){
		// console.log("Inside reload record");
		// console.log( record );
		var list = this.getList();
		var store = this.getList().getStore();
		var modifiedId = record.get('id');
		
		console.log("in reloadRecord");
		console.log( record) ;
		
		AM.model.AssetDetail.load( modifiedId , {
		    scope: list,
		    failure: function(record, master) {
		        //do something if the load failed
		    },
		    success: function(record, master) {
			
					recToUpdate = store.getById(modifiedId);
					recToUpdate.set(record.getData());
					recToUpdate.commit();
					list.getView().refreshNode(store.indexOfId(modifiedId));
					list.enableRecordButtons();
		    },
		    callback: function(record, master) {
		        //do something whether the load succeeded or failed
		    }
		});
	},
	
	
	assignObject: function(){
	 
		
		var me = this; 
    var record = this.getList().getSelectedObject();
		var parentObject1  = this.getParentList1().getSelectedObject();
		var parentObject2  = this.getParentList1().getSelectedObject();
		
		if( record ) {
			var view = Ext.widget('assetdetailassignform');
			view.show();
			view.setExtraParamForJsonRemoteStore( record.get("component_id")); // component_id
			view.setParentData1(parentObject1);
			view.setParentData2(parentObject2);
			view.setComboBoxData( record ) ;
			view.down('form').loadRecord(record);
		}
		
		

    

	},
	
	
	executeAssignObject: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();
		
		var parentObject1  = this.getParentList1().getSelectedObject();
		var parentObject2  = this.getParentList1().getSelectedObject();

    var store = this.getAssetDetailsStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'initial_item_id' , values['initial_item_id'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					assign: true 
				},
				success : function(record){
					form.setLoading(false);
					
					me.reloadRecord( record ) ; 
					// store.load();
					// parentList.enableRecordButtons();
					
					win.close();
				},
				failure : function(record,op ){
					// console.log("Fail update");
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					record.reject(); 
					// this.reject(); 
				}
			});
		}
	},
	


	

});
