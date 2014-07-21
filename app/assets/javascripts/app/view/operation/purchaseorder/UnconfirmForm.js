Ext.define('AM.view.operation.purchaseorder.UnconfirmForm', {
  extend: 'Ext.window.Window',
  alias : 'widget.unconfirmpurchaseorderform',

  title : 'Unconfirm StockAdjustment',
  layout: 'fit',
	width	: 400,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
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
					xtype: 'displayfield',
					fieldLabel: 'Tanggal Konfirmasi',
					name: 'confirmed_at' 
				} 
		 
			]
    }];

    this.buttons = [{
      text: 'Unconfirm',
      action: 'unconfirm'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	setParentData: function( record ) {
		// this.down('form').getForm().findField('group_loan_name').setValue(record.get('group_loan_name')); 
		// this.down('form').getForm().findField('week_number').setValue(record.get('week_number')); 
		this.down('form').getForm().findField('confirmed_at').setValue(record.get('confirmed_at')); 
	}
});
