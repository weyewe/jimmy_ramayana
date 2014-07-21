Ext.define('AM.view.operation.purchaseorder.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.purchaseorderform',

  title : 'Add / Edit Purchase Order',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
		var remoteJsonStoreContact = Ext.create(Ext.data.JsonStore, {
			storeId : 'contact_search',
			fields	: [
			 		{
						name : 'contact_name',
						mapping : "name"
					} ,
					{
						name : 'contact_description',
						mapping : "description"
					} ,
					
					{
						name : 'contact_id',
						mapping : "id"
					}  
			],
			
		 
			proxy  	: {
				extraParams : {
					parent_id : null
				},
				type : 'ajax',
				url : 'api/search_contact',
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
					fieldLabel: 'Contact',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'contact_name',
					valueField : 'contact_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreContact , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{contact_name}">' + 
													'<div class="combo-name">{contact_name}</div>' +   
													'<div>{contact_description}</div>' + 
							 					'</div>';
						}
					},
					name : 'contact_id' 
				},
				
				{
					xtype: 'datefield',
					name : 'purchase_date',
					fieldLabel: 'Tanggal Pembelian',
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

	 
	setSelectedContact: function( contact_id ){
		var comboBox = this.down('form').getForm().findField('contact_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : contact_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( contact_id );
			}
		});
	},

	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		
		me.setSelectedContact( record.get("contact_id")  ) ; 
	},
	
});

