Ext.define('AM.view.operation.maintenance.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.maintenanceform',

  title : 'Add / Edit Maintenance',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
		var remoteJsonStoreAsset = Ext.create(Ext.data.JsonStore, {
			storeId : 'asset_search',
			fields	: [
			 		{
						name : 'asset_contact_name',
						mapping : "contact_name"
					} ,
					{
						name : 'asset_code',
						mapping : "code"
					} ,
					{
						name : 'asset_machine_name',
						mapping : "machine_name"
					} ,
					
					{
						name : 'asset_id',
						mapping : "id"
					}  
			],
			
		 
			proxy  	: {
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_asset',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
		
		var remoteJsonStoreWarehouse = Ext.create(Ext.data.JsonStore, {
			storeId : 'warehouse_search',
			fields	: [
			 		{
						name : 'warehouse_name',
						mapping : "name"
					} ,
					{
						name : 'warehouse_description',
						mapping : "description"
					} ,
					
					{
						name : 'warehouse_id',
						mapping : "id"
					}  
			],
			
		 
			proxy  	: {
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_warehouse',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
	  
    this.items = [{
      xtype: 'form',
			msgTarget	: 'side',
			border: false,
      bodyPadding: 10,
			fieldDefaults: {
          labelWidth: 165,
					anchor: '100%'
      },
      items: [
				{
	        xtype: 'hidden',
	        name : 'id',
	        fieldLabel: 'id'
	      },
				{
					fieldLabel: 'Asset',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'asset_code',
					valueField : 'asset_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreAsset , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{asset_code}">' + 
													'<div class="combo-name">{asset_code}</div>' +   
													'<div>{asset_contact_name}</div>' + 
							 					'</div>';
						}
					},
					name : 'asset_id' 
				},
				{
					fieldLabel: 'Warehouse',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'warehouse_name',
					valueField : 'warehouse_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreWarehouse , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{warehouse_name}">' + 
													'<div class="combo-name">{warehouse_name}</div>' +   
													'<div>{warehouse_description}</div>' + 
							 					'</div>';
						}
					},
					name : 'warehouse_id' 
				},
				{
					xtype: 'datefield',
					name : 'complaint_date',
					fieldLabel: 'Tanggal Request',
					format: 'Y-m-d',
				},
				
				{
					xtype: 'textfield',
					name : 'complaint',
					fieldLabel: 'Deskripsi'
				},
				
			]
    }];

    this.buttons = [{
      text: 'Save',
      action: 'save'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	 
	setSelectedAsset: function( asset_id ){
		var comboBox = this.down('form').getForm().findField('asset_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : asset_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( asset_id );
			}
		});
	},
	
	setSelectedWarehouse: function( warehouse_id ){
		var comboBox = this.down('form').getForm().findField('warehouse_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : warehouse_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( warehouse_id );
			}
		});
	},

	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		
		me.setSelectedAsset( record.get("asset_id")  ) ; 
		me.setSelectedWarehouse( record.get("warehouse_id")  ) ; 
	},
	
});

