Ext.define('AM.view.master.item.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.itemform',

  title : 'Add / Edit Item',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		var me = this; 

		var remoteJsonStoreType = Ext.create(Ext.data.JsonStore, {
			storeId : 'type_search',
			fields	: [
			{
				name : 'item_type_name',
				mapping : "name"
				} ,
				{
					name : 'item_type_id',
					mapping : "id"
				}  
				],


				proxy  	: {
					type : 'ajax',
					url : 'api/search_item_type',
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
	        name : 'item_type_id',
	        fieldLabel: 'Item Type Id'
	      },
				{
	        xtype: 'displayfield',
	        name : 'item_type_name',
	        fieldLabel: 'Item Category'
	      },
			
				
				{
					xtype: 'textfield',
					name : 'sku',
					fieldLabel: 'SKU'
				},
				{
					xtype: 'textarea',
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

	
	setSelectedType: function( item_type_id ){
		// var comboBox = this.down('form').getForm().findField('item_type_id'); 
		// var me = this; 
		// var store = comboBox.store;  
		// store.load({
		// 	params: {
		// 		selected_id : item_type_id 
		// 	},
		// 	callback : function(records, options, success){
		// 		me.setLoading(false);
		// 		comboBox.setValue( item_type_id );
		// 	}
		// });
	},

	setComboBoxData : function( record){
		// console.log("gonna set combo box data");
		// var me = this; 
		// me.setLoading(true);
		// 
		// me.setSelectedType( record.get("item_type_id")  ) ; 
	},
	
	setParentData: function( record ){
		// this.down('form').getForm().findField('customer_name').setValue(record.get('name')); 
		// this.down('form').getForm().findField('customer_id').setValue(record.get('id'));
		this.down('form').getForm().findField('item_type_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('item_type_id').setValue(record.get('id')); 
	},
});

