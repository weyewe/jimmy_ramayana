Ext.define('AM.view.operation.purchasereceivaldetail.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.purchasereceivaldetailform',

  title : 'Add / Edit PurchaseReceivalDetail',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
		var remoteJsonStorePurchaseOrderDetail = Ext.create(Ext.data.JsonStore, {
			storeId : 'pod_search',
			fields	: [
			 		{
						name : 'item_sku',
						mapping : "item_sku"
					} ,
					{
						name : 'item_description',
						mapping : "item_description"
					} ,
					
					{
						name : 'purchase_order_id',
						mapping : "purchase_order_id"
					} ,
					
					{
						name : 'purchase_order_detail_id',
						mapping : "id"
					}  
			],
			
		 
			proxy  	: {
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_purchase_order_detail',
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
	        xtype: 'hidden',
	        name : 'purchase_receival_id',
	        fieldLabel: 'purchase receival id  '
	      },
				{
					fieldLabel: 'Item',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'item_sku',
					valueField : 'purchase_order_detail_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStorePurchaseOrderDetail , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{item_sku}">' + 
													'<div class="combo-name">{item_sku}</div>' +   
													'<div>{item_description}</div>' + 
													'<div>PO ID: {purchase_order_id}</div>' + 
							 					'</div>';
						}
					},
					name : 'purchase_order_detail_id' 
				},
				
				{
	        xtype: 'textfield',
	        name : 'quantity',
	        fieldLabel: 'Quantity'
	      } 
				
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

	setSelectedItem: function( item_id ){
		var comboBox = this.down('form').getForm().findField('purchase_order_detail_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : item_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( item_id );
			}
		});
	},

	setComboBoxData : function( record){
		
		var me = this; 
		me.setLoading(true);
		
		me.setSelectedItem( record.get("item_id")  ) ; 
	},
	
	setExtraParamInPurchaseOrderDetailComboBox: function(parent_id){
		
		var comboBox = this.down('form').getForm().findField('purchase_order_detail_id'); 
		var store = comboBox.store;
		
		store.getProxy().extraParams.parent_id =  parent_id;
	},
	
	setExtraParamForJsonRemoteStore: function( parent_id ) {
		// console.log("Inside setExtraParamForJsonRemoteStore ");
		var me =this;
		me.setExtraParamInPurchaseOrderDetailComboBox( parent_id );
	},
	
	
	setParentData: function( record ){
		this.down('form').getForm().findField('purchase_receival_id').setValue(record.get('id')); 
	},
});

