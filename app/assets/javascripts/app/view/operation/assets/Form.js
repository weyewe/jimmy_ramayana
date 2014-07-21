Ext.define('AM.view.operation.asset.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.assetform',

  title : 'Add / Edit Asset',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		var me = this; 
	 
		var remoteJsonStoreMachine = Ext.create(Ext.data.JsonStore, {
			storeId : 'machine_search',
			fields	: [
			 		{
						name : 'machine_name',
						mapping : "name"
					} ,
					{
						name : 'machine_description',
						mapping : "description"
					} ,
					
					{
						name : 'machine_brand',
						mapping : "brand"
					} ,
					{
						name : 'machine_id',
						mapping : "id"
					}  
			],
			
		 
			proxy  	: {
				type : 'ajax',
				url : 'api/search_machine',
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
	        name : 'contact_id',
	        fieldLabel: 'Contact ID'
	      },
				{
					xtype: 'displayfield',
					fieldLabel: 'Contact',
					name: 'contact_name' ,
					value : '10' 
				},
			
				{
					fieldLabel: 'Machine',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'machine_name',
					valueField : 'machine_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStoreMachine , 
					listConfig : {
						getInnerTpl: function(){
							return  	'<div data-qtip="{machine_name}">' + 
													'<div class="combo-name">{machine_name} | {machine_brand}</div>' + 
													'<div>{machine_description}</div>' + 
													
							 					'</div>';
						}
					},
					name : 'machine_id' 
				},
				
				{
					xtype: 'textfield',
					name : 'code',
					fieldLabel: 'Code'
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

	
	setSelectedMachine: function( machine_id ){
		var comboBox = this.down('form').getForm().findField('machine_id'); 
		var me = this; 
		var store = comboBox.store;  
		store.load({
			params: {
				selected_id : machine_id 
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( machine_id );
			}
		});
	},

	setComboBoxData : function( record){
		console.log("gonna set combo box data");
		var me = this; 
		me.setLoading(true);
		
		me.setSelectedMachine( record.get("machine_id")  ) ; 
	},
	
	setParentData: function( record ){
		this.down('form').getForm().findField('contact_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('contact_id').setValue(record.get('id')); 
	},
});

