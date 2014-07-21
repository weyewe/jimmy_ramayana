Ext.define('AM.controller.PurchaseReceivals', {
  extend: 'Ext.app.Controller',

  stores: ['PurchaseReceivals', 'PurchaseReceivalDetails'],
  models: ['PurchaseReceivalDetail', 'PurchaseReceival'],

  views: [
    'operation.purchasereceivaldetail.List',
    'operation.purchasereceivaldetail.Form',
		'operation.purchasereceival.List',
    'operation.purchasereceival.Form', 
		'operation.PurchaseReceival'
  ],

  	refs: [
		{
			ref : "wrapper",
			selector : "purchasereceivalProcess"
		},
		{
			ref : 'parentList',
			selector : 'purchasereceivalProcess purchasereceivallist'
		},
		{
			ref: 'list',
			selector: 'purchasereceivalProcess purchasereceivaldetaillist'
		},
		{
			ref : 'searchField',
			selector: 'purchasereceivaldetaillist textfield[name=searchField]'
		}
	],

  init: function() {
    this.control({
			'purchasereceivalProcess purchasereceivallist' : {
				afterrender : this.loadParentObjectList,
				selectionchange: this.parentSelectionChange,
				
				destroy : this.onParentDestroy 
			},
			
		 
			
			'purchasereceivalform button[action=save]': {
        click: this.updateParentObject
      },
      'purchasereceivalProcess purchasereceivallist  button[action=addObject]': {
        click: this.addParentObject
      },
      'purchasereceivalProcess purchasereceivallist  button[action=editObject]': {
        click: this.editParentObject
      },
      'purchasereceivalProcess purchasereceivallist button[action=deleteObject]': {
        click: this.deleteParentObject
      },

			'purchasereceivalProcess purchasereceivallist button[action=confirmObject]': {
        click: this.confirmObject
			}	,
			
			'confirmpurchasereceivalform button[action=confirm]' : {
				click : this.executeConfirm
			},
			
			'purchasereceivalProcess purchasereceivallist button[action=unconfirmObject]': {
        click: this.unconfirmObject
			}	,
			
			'unconfirmpurchasereceivalform button[action=unconfirm]' : {
				click : this.executeUnconfirm
			},
			
			'purchasereceivalProcess purchasereceivallist textfield[name=searchField]': {
        change: this.liveSearch
      },


	
      'purchasereceivaldetaillist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				// afterrender : this.loadObjectList,
      },
      'purchasereceivaldetailform button[action=save]': {
        click: this.updateObject
      },
      'purchasereceivaldetaillist button[action=addObject]': {
        click: this.addObject
      },
      'purchasereceivaldetaillist button[action=editObject]': {
        click: this.editObject
      },
      'purchasereceivaldetaillist button[action=deleteObject]': {
        click: this.deleteObject
      },


			'purchasereceivaldetaillist button[action=deactivateObject]': {
        click: this.deactivateObject
			}	,
			
			'deactivatepurchasereceivaldetailform button[action=confirmDeactivate]' : {
				click : this.executeDeactivate
			},
		
    });
  },
 
	onParentDestroy: function(){
		this.getPurchaseReceivalDetailsStore().loadData([],false);
	},

	liveSearch : function(grid, newValue, oldValue, options){
		var me = this;

		me.getPurchaseReceivalsStore().getProxy().extraParams = {
		    livesearch: newValue
		};
	 
		me.getPurchaseReceivalsStore().load();
	},
 

	loadObjectList : function(me){
		me.getStore().load();
	},
	
	loadParentObjectList: function(me){
		me.getStore().getProxy().extraParams =  {};
		me.getStore().load(); 
	},
	
	
	addParentObject: function() {
		var view = Ext.widget('purchasereceivalform');
		view.show(); 
  },

  editParentObject: function() {
		var me = this; 
    var record = this.getParentList().getSelectedObject();

		if( record){
			var view = Ext.widget('purchasereceivalform');
			view.setComboBoxData( record );
	    view.down('form').loadRecord(record);
		}
  },

  updateParentObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList = this.getParentList();
		var wrapper = this.getWrapper();

    var store = this.getPurchaseReceivalsStore();
		var childStore = this.getPurchaseReceivalDetailsStore(); 
    var record = form.getRecord();
    var values = form.getValues();

// console.log("The values: " ) ;
// console.log( values );

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					
					// store.getProxy().extraParams = {
					//     livesearch: ''
					// };
	 
					store.load();
					childStore.load({
						params: {
							parent_id : wrapper.selectedParentId 
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
			var newObject = new AM.model.PurchaseReceival( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){

					
					store.load();
					
					childStore.load({
						params: {
							parent_id : wrapper.selectedParentId 
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

  deleteParentObject: function() {
		
    var parentObject = this.getParentList().getSelectedObject();
		
    if (parentObject) {
	
      var store = this.getParentList().store;
      store.remove(parentObject);
      store.sync();
			this.getParentList().query('pagingtoolbar')[0].doRefresh();
			this.getList().store.loadData([],false);
			
			this.getParentList().disableRecordButtons();
			this.getList().disableAddButton();
    }
  },
	
	
	
	/*
	==============================> Parent 
	*/

  addObject: function() {
	
    
		var parentObject  = this.getParentList().getSelectedObject();
		if( parentObject) {
			var view = Ext.widget('purchasereceivaldetailform');
			view.show();
			view.setParentData(parentObject);
			view.setExtraParamForJsonRemoteStore( parentObject.get("purchase_order_id"));
		}
  },

  editObject: function() {
		var me = this; 
    var record = this.getList().getSelectedObject();

		var parentObject  = this.getParentList().getSelectedObject();
		if( parentObject) {
			var view = Ext.widget('purchasereceivaldetailform');
			view.show();
			view.setParentData(parentObject);
			view.setExtraParamForJsonRemoteStore( parentObject.get("purchase_order_id"));
			view.setComboBoxData( record );
			view.down('form').loadRecord(record);
		}
  },

  updateObject: function(button) {
		var me = this; 
    var win = button.up('window');
    var form = win.down('form');
		var parentList = this.getParentList();
		var wrapper = this.getWrapper();

    var store = this.getPurchaseReceivalDetailsStore();
    var record = form.getRecord();
    var values = form.getValues();

// console.log("The values: " ) ;
// console.log( values );

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					
					// store.getProxy().extraParams = {
					//     livesearch: ''
					// };
	 
					store.load({
						params: {
							parent_id : wrapper.selectedParentId 
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
			var newObject = new AM.model.PurchaseReceivalDetail( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
	
					store.load({
						params: {
							parent_id : wrapper.selectedParentId 
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
      var store = this.getPurchaseReceivalDetailsStore();
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

	deactivateObject: function(){
		// console.log("mark as Deceased is clicked");
		var view = Ext.widget('deactivatepurchasereceivaldetailform');
		var record = this.getList().getSelectedObject();
		view.setParentData( record );
		// view.down('form').getForm().findField('c').setValue(record.get('deceased_at')); 
    view.show();
	},
	
	executeDeactivate : function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getPurchaseReceivalDetailsStore();
		var record = this.getList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'deactivation_case' , values['deactivation_case'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					deactivate: true 
				},
				success : function(record){
					form.setLoading(false);
					
					// list.fireEvent('confirmed', record);
					
					
					store.load();
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

	parentSelectionChange: function(selectionModel, selections) {
		if( selections == 0 ){
			return; 
		}
		var me = this; 
    var grid = me.getList();
		var parentList = me.getParentList();
		var wrapper = me.getWrapper();
		
		// console.log("parent selection change");
		// console.log("The wrapper");
		// console.log( wrapper ) ;

    if (selections.length > 0) {
			grid.enableAddButton();
			parentList.enableRecordButtons();
      // grid.enableRecordButtons();
    } else {
			grid.disableAddButton();
			parentList.disableRecordButtons();
      // grid.disableRecordButtons();
    }
		
		 
		if (parentList.getSelectionModel().hasSelection()) {
			var row = parentList.getSelectionModel().getSelection()[0];
			var id = row.get("id"); 
			wrapper.selectedParentId = id ; 
		}
		
		
		
		// console.log("The parent ID: "+ wrapper.selectedParentId );
		
		// grid.setLoading(true); 
		grid.getStore().getProxy().extraParams.parent_id =  wrapper.selectedParentId ;
		grid.getStore().load(); 
  },


	confirmObject: function(){
		var view = Ext.widget('confirmpurchasereceivalform');
		var record = this.getParentList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	unconfirmObject: function(){
		var view = Ext.widget('unconfirmpurchasereceivalform');
		var record = this.getParentList().getSelectedObject();
		view.setParentData( record );
    view.show();
		// this.reloadRecordView( record, view ) ; 
	},
	
	reloadRecord: function(record){
		// console.log("Inside reload record");
		// console.log( record );
		var list = this.getParentList();
		var store = this.getParentList().getStore();
		var modifiedId = record.get('id');
		
		AM.model.PurchaseReceival.load( modifiedId , {
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
	
	
	executeConfirm: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();
		var parentList  = this.getParentList();

    var store = this.getPurchaseReceivalsStore();
		var record = this.getParentList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'confirmed_at' , values['confirmed_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					confirm: true 
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
	
	executeUnconfirm: function(button){
		var me = this; 
		var win = button.up('window');
    var form = win.down('form');
		var list = this.getList();

    var store = this.getPurchaseReceivalsStore();
		var record = this.getParentList().getSelectedObject();
    var values = form.getValues();
 
		if(record){
			var rec_id = record.get("id");
			record.set( 'confirmed_at' , values['confirmed_at'] );
			 
			// form.query('checkbox').forEach(function(checkbox){
			// 	record.set( checkbox['name']  ,checkbox['checked'] ) ;
			// });
			// 
			form.setLoading(true);
			record.save({
				params : {
					unconfirm: true 
				},
				success : function(record){
					form.setLoading(false);
					
					me.reloadRecord( record ) ; 
					// store.load();
					
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
