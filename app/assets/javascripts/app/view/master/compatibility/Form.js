Ext.define('AM.view.master.compatibility.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.compatibilityform',

  title : 'Add / Edit Compatibility',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		var me = this; 
	  
	
		var remoteJsonStoreItem = Ext.create(Ext.data.JsonStore, {
			storeId : 'item_search',
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
	        name : 'component_id',
	        fieldLabel: 'COMPONENT ID '
	      },
				{
					xtype: 'displayfield',
					fieldLabel: 'Machine',
					name: 'machine_name' ,
					value : '10' 
				},
				
				{
					xtype: 'displayfield',
					fieldLabel: 'Component',
					name: 'component_name' ,
					value : '10' 
				},
				{
					fieldLabel: 'Item',
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
					name : 'item_id' 
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
		var comboBox = this.down('form').getForm().findField('item_id'); 
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
		console.log("gonna set combo box data");
		var me = this; 
		me.setLoading(true);
		
		me.setSelectedItem( record.get("item_id")  ) ;
	},
	
	setParentData1: function( record ){
		this.down('form').getForm().findField('machine_name').setValue(record.get('name')); 
	},
	
	setParentData2: function( record ){
		this.down('form').getForm().findField('component_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('component_id').setValue(record.get('id')); 
	},
});

