Ext.define('AM.view.operation.assetdetail.AssignForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.assetdetailassignform',

  title : 'Assign Initial Item',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		var me = this; 
	  
		var remoteJsonStoreItem = Ext.create(Ext.data.JsonStore, {
			storeId : 'assign_item_search',
			fields	: [
			 		{
						name : 'item_sku',
						mapping : "sku"
					} ,
					{
						name : 'item_description',
						mapping : "description"
					} ,
					{
						name : 'item_id',
						mapping : "id"
					} 
			],
			
		 
			proxy  	: {
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_item',
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
	        name : 'asset_id',
	        fieldLabel: 'Asset ID'
	      },
				{
					xtype: 'displayfield',
					fieldLabel: 'Asset',
					name: 'asset_code' ,
					value : '10' 
				},
				
				{
					xtype: 'displayfield',
					fieldLabel: 'Component',
					name: 'component_name' ,
					value : '10' 
				},
				
				{
					fieldLabel: 'Initial Item',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'item_sku',
					valueField : 'item_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreItem , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{item_sku}">' + 
													'<div class="combo-name">{item_sku}</div>' + 
													'<div>{item_description}</div>' +  
							 					'</div>';
						}
					},
					name : 'initial_item_id' 
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

	
	
	setExtraParamInItemComboBox: function(parent_id){
		
		var comboBox = this.down('form').getForm().findField('initial_item_id'); 
		var store = comboBox.store;
		
		store.getProxy().extraParams.parent_id =  parent_id;
	},
	
	setExtraParamForJsonRemoteStore: function( parent_id ) {
		var me =this;
		me.setExtraParamInItemComboBox( parent_id );
	},
	
	
 
	setSelectedInitialItem: function( initial_item_id ){
		var comboBox = this.down('form').getForm().findField('initial_item_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : initial_item_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( initial_item_id );
			}
		});
	},

	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		
		me.setSelectedInitialItem( record.get("initial_item_id")  ) ; 
	},
	
	
	setParentData1: function( record ){
		
	},
	
	setParentData2: function( record ){
		this.down('form').getForm().findField('asset_code').setValue(record.get('code')); 
		this.down('form').getForm().findField('component_name').setValue(record.get('component_name')); 
	},
});

