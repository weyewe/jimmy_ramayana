Ext.define('AM.view.operation.deliveryorder.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.deliveryorderform',

  title : 'Add / Edit DeliveryOrder',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
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
		
		var remoteJsonStorePurchaseOrder = Ext.create(Ext.data.JsonStore, {
			storeId : 'po_search',
			fields	: [
			 		{
						name : 'sales_order_id',
						mapping : "id"
					} ,
					{
						name : 'sales_order_description',
						mapping : "description"
					} 
			],
			
		 
			proxy  	: {
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_sales_order',
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
					fieldLabel: 'PurchaseOrder',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'sales_order_id',
					valueField : 'sales_order_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStorePurchaseOrder, 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{sales_order_id}">' + 
													'<div class="combo-name">{sales_order_id}</div>' +   
													'<div>{sales_order_description}</div>' + 
							 					'</div>';
						}
					},
					name : 'sales_order_id' 
				},
				
				{
					xtype: 'datefield',
					name : 'delivery_date',
					fieldLabel: 'Tanggal Penerimaan',
					format: 'Y-m-d',
				},
				
				{
					xtype: 'textfield',
					name : 'description',
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
	
	setSelectedPurchaseOrder: function( sales_order_id ){
		var comboBox = this.down('form').getForm().findField('sales_order_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : sales_order_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( sales_order_id );
			}
		});
	},

	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		
		me.setSelectedWarehouse( record.get("warehouse_id")  ) ; 
		me.setSelectedPurchaseOrder( record.get("sales_order_id")  ) ; 
	},
	
});

