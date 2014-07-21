Ext.define("AM.controller.Operation", {
	extend : "AM.controller.BaseTreeBuilder",
	views : [
		"operation.OperationProcessList",
		'OperationProcessPanel',
		'Viewport'
	],

	 
	
	refs: [
		{
			ref: 'operationProcessPanel',
			selector: 'operationProcessPanel'
		} ,
		{
			ref: 'operationProcessList',
			selector: 'operationProcessList'
		}  
	],
	

	 
	init : function( application ) {
		var me = this; 
		 
		// console.log("starting the init in Operation.js");
		me.control({
			"operationProcessPanel" : {
				activate : this.onActiveProtectedContent,
				deactivate : this.onDeactivated
			} 
			
		});
		
	},
	
	onDeactivated: function(){
		// console.log("Operation process panel is deactivated");
		var worksheetPanel = Ext.ComponentQuery.query("operationProcessPanel #operationWorksheetPanel")[0];
		worksheetPanel.setTitle(false);
		// worksheetPanel.setHeader(false);
		worksheetPanel.removeAll();		 
		var defaultWorksheet = Ext.create( "AM.view.operation.Default");
		worksheetPanel.add(defaultWorksheet); 
	},
	
	 

	scheduledFolder : {
		text 			: "ASSET Builder", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [
        
// select customer. then create the asset 
			{ 
				text:'Asset', 
				viewClass:'AM.view.operation.Asset', 
				leaf:true, 
				iconCls:'text',
				conditions : [
				{
					controller : 'assets',
					action : 'index'
				}
				]
			}, 
			
		// select customer, select asset, then assign current item or add new component 
			{ 
				text:'Asset Setup', 
				viewClass:'AM.view.operation.AssetDetail', 
				leaf:true, 
				iconCls:'text',
				conditions : [
				{
					controller : 'assets',
					action : 'index'
				}
				]
			},
			
			// do maintenance
			
			{ 
				text:'Maintenance', 
				viewClass:'AM.view.operation.Maintenance', 
				leaf:true, 
				iconCls:'text',
				conditions : [
				{
					controller : 'maintenances',
					action : 'index'
				}
				]
			},
			
			 
    ]
	},
	
	stockFolder : {
		text 			: "Stock", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [
        
			{ 
				text:'Stock Adjustment', 
				viewClass:'AM.view.operation.StockAdjustment', 
				leaf:true, 
				iconCls:'text',
				conditions : [
				{
					controller : 'stock_adjustments',
					action : 'index'
				}
				]
			}, 
			 
    ]
	},
	
	tradingFolder : {
		text 			: "Trading", 
		viewClass : '',
		iconCls		: 'text-folder', 
    expanded	: true,
		children 	: [
        
			{ 
				text:'PurchaseOrder', 
				viewClass:'AM.view.operation.PurchaseOrder', 
				leaf:true, 
				iconCls:'text',
				conditions : [
					{
						controller : 'purchase_orders',
						action : 'index'
					}
				]
			},
			{ 
				text:'PurchaseReceival', 
				viewClass:'AM.view.operation.PurchaseReceival', 
				leaf:true, 
				iconCls:'text',
				conditions : [
					{
						controller : 'purchase_receivals',
						action : 'index'
					}
				]
			},
			{ 
				text:'SalesOrder', 
				viewClass:'AM.view.operation.SalesOrder', 
				leaf:true, 
				iconCls:'text',
				conditions : [
					{
						controller : 'sales_orders',
						action : 'index'
					}
				]
			},
			{ 
				text:'DeliveryOrder', 
				viewClass:'AM.view.operation.DeliveryOrder', 
				leaf:true, 
				iconCls:'text',
				conditions : [
					{
						controller : 'delivery_orders',
						action : 'index'
					}
				]
			},
    ]
	},
	   
	 
	onActiveProtectedContent: function( panel, options) {
		var me  = this; 
		var currentUser = Ext.decode( localStorage.getItem('currentUser'));
		var email = currentUser['email'];
		
		me.folderList = [
			this.scheduledFolder,
			this.stockFolder,
			this.tradingFolder
			
			// this.emergencyFolder
			// this.inventoryFolder,
			// this.reportFolder,
			// this.projectReportFolder
		];
		
		var processList = panel.down('operationProcessList');
		processList.setLoading(true);
	
		var treeStore = processList.getStore();
		treeStore.removeAll(); 
		
		treeStore.setRootNode( this.buildNavigation(currentUser) );
		processList.setLoading(false);
	},
});