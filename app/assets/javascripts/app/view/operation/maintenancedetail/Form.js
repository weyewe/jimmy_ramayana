Ext.define('AM.view.operation.maintenancedetail.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.maintenancedetailform',

  title : 'Add / Edit Maintenance Detail',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
	
	 
		var remoteJsonStoreItem = Ext.create(Ext.data.JsonStore, {
			storeId : 'warehouse_search',
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
		
		
		var localJsonStoreDiagnosisCase = Ext.create(Ext.data.Store, {
			type : 'array',
			storeId : 'diagnosis_case_search',
			fields	: [ 
				{ name : "diagnosis_case"}, 
				{ name : "diagnosis_case_text"}  
			], 
			data : [
				{ diagnosis_case : 1, diagnosis_case_text : "OK"},
				{ diagnosis_case : 2, diagnosis_case_text : "Butuh Perbaikan"},
				{ diagnosis_case : 3, diagnosis_case_text : "Butuh Penggantian"},
			] 
		});
		
		var localJsonStoreSolutionCase = Ext.create(Ext.data.Store, {
			type : 'array',
			storeId : 'solution_case_search',
			fields	: [ 
				{ name : "solution_case"}, 
				{ name : "solution_case_text"}  
			], 
			data : [
				{ solution_case : 2, solution_case_text : "Pending"},
				{ solution_case : 3, solution_case_text : "Selesai"}
			] 
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
					// Fieldset in Column 2 - collapsible via checkbox, collapsed by default, contains a panel
					xtype:'fieldset',
					title: 'Diagnosis', // title or checkboxToggle creates fieldset header  
					layout:'anchor',
					items :[
						{
							fieldLabel: 'Kasus Diagnosa',
							xtype: 'combo',
							queryMode: 'remote',
							forceSelection: true, 
							displayField : 'diagnosis_case_text',
							valueField : 'diagnosis_case_id',
							pageSize : 5,
							minChars : 1, 
							allowBlank : false, 
							triggerAction: 'all',
							store : localJsonStoreDiagnosisCase , 
							listConfig : {
								getInnerTpl: function(){
									return  	'<div data-qtip="{diagnosis_case_text}">' +  
															'<div class="combo-name">{diagnosis_case_text}</div>' +  
									 					'</div>';
								}
							},
							name : 'diagnosis_case' 
						}, 
						{
			        xtype: 'textarea',
			        name : 'diagnosis',
			        fieldLabel: 'Deskripsi Diagnosa'
			      },
					]
				},
				
				{
					// Fieldset in Column 2 - collapsible via checkbox, collapsed by default, contains a panel
					xtype:'fieldset',
					title: 'Solusi', // title or checkboxToggle creates fieldset header  
					layout:'anchor',
					items :[
						{
							fieldLabel: 'Kasus Solusi',
							xtype: 'combo',
							queryMode: 'remote',
							forceSelection: true, 
							displayField : 'solution_case_text',
							valueField : 'solution_case_id',
							pageSize : 5,
							minChars : 1, 
							allowBlank : false, 
							triggerAction: 'all',
							store : localJsonStoreSolutionCase , 
							listConfig : {
								getInnerTpl: function(){
									return  	'<div data-qtip="{solution_case_text}">' +  
															'<div class="combo-name">{solution_case_text}</div>' +  
									 					'</div>';
								}
							},
							name : 'solution_case' 
						}, 
						{
			        xtype: 'textarea',
			        name : 'solution',
			        fieldLabel: 'Deskripsi Solusi'
			      },
						{
							xtype: 'checkbox',
							name : 'is_replacement_required',
							fieldLabel: 'Butuh Penggantian?'
						},
						{
							fieldLabel: 'Item Pengganti',
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
							name : 'replacement_item_id' 
						},
					]
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
		var me = this; 
		me.setLoading(true);
		
		me.setSelectedItem( record.get("item_id")  ) ; 
	},
	
	setParentData: function( record ){
		this.down('form').getForm().findField('purchase_order_id').setValue(record.get('id')); 
	},
});

