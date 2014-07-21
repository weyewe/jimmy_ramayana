Ext.define('AM.view.operation.deliveryorderdetail.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.deliveryorderdetailform',

  title : 'Add / Edit DeliveryOrderDetail',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
		var remoteJsonStoreSalesOrderDetail = Ext.create(Ext.data.JsonStore, {
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
						name : 'sales_order_id',
						mapping : "sales_order_id"
					} ,
					
					{
						name : 'sales_order_detail_id',
						mapping : "id"
					}  
			],
			
		 
			proxy  	: {
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_sales_order_detail',
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
	        name : 'delivery_order_id',
	        fieldLabel: 'delivery order id  '
	      },
				{
					fieldLabel: 'Item',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'item_sku',
					valueField : 'sales_order_detail_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreSalesOrderDetail , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{item_sku}">' + 
													'<div class="combo-name">{item_sku}</div>' +   
													'<div>{item_description}</div>' + 
													'<div>SO ID: {sales_order_id}</div>' + 
							 					'</div>';
						}
					},
					name : 'sales_order_detail_id' 
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
		var comboBox = this.down('form').getForm().findField('sales_order_detail_id'); 
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
	
	setExtraParamInSalesOrderDetailComboBox: function(parent_id){
		
		var comboBox = this.down('form').getForm().findField('sales_order_detail_id'); 
		var store = comboBox.store;
		
		store.getProxy().extraParams.parent_id =  parent_id;
	},
	
	setExtraParamForJsonRemoteStore: function( parent_id ) {
		var me =this;
		me.setExtraParamInSalesOrderDetailComboBox( parent_id );
	},
	
	
	setParentData: function( record ){
		this.down('form').getForm().findField('delivery_order_id').setValue(record.get('id')); 
	},
});

