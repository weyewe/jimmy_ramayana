Ext.define('AM.view.operation.assetdetail.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.assetdetailform',

  title : 'Add / Edit Part',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		var me = this; 
	  
		var remoteJsonStoreComponent = Ext.create(Ext.data.JsonStore, {
			storeId : 'component_search',
			fields	: [
			 		{
						name : 'component_name',
						mapping : "name"
					} ,
					{
						name : 'component_id',
						mapping : "id"
					}  
			],
			
		 
			proxy  	: {
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_component',
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
					fieldLabel: 'Component',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'component_name',
					valueField : 'component_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreComponent , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{component_name}">' + 
													'<div class="combo-name">{component_name}</div>' +  
							 					'</div>';
						}
					},
					name : 'component_id' 
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

	
	
	setExtraParamInAssetDetailComboBox: function(parent_id){
		
		var comboBox = this.down('form').getForm().findField('component_id'); 
		var store = comboBox.store;
		
		store.getProxy().extraParams.parent_id =  parent_id;
	},
	
	setExtraParamForJsonRemoteStore: function( parent_id ) {
		var me =this;
		me.setExtraParamInAssetDetailComboBox( parent_id );
	},
	
	

	setComboBoxData : function( record){ 
	 
	},
	
	setParentData1: function( record ){
		
	},
	
	setParentData2: function( record ){
		this.down('form').getForm().findField('asset_code').setValue(record.get('code')); 
		this.down('form').getForm().findField('asset_id').setValue(record.get('id')); 
	},
});

