Ext.define('AM.view.master.component.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.componentform',

  title : 'Add / Edit Component',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		var me = this; 
	 
	 
		
		
		 
		
		
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
	        name : 'machine_id',
	        fieldLabel: 'Machine ID'
	      },
				{
					xtype: 'displayfield',
					fieldLabel: 'Machine',
					name: 'machine_name' ,
					value : '10' 
				},
				{
					xtype: 'textfield',
					fieldLabel: 'Name',
					name: 'name'  
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
		// var me = this; 
		// me.setLoading(true);
		// 
		// me.setSelectedType( record.get("item_type_id")  ) ; 
	},
	
	setParentData: function( record ){
		this.down('form').getForm().findField('machine_name').setValue(record.get('name')); 
		this.down('form').getForm().findField('machine_id').setValue(record.get('id')); 
	},
});

