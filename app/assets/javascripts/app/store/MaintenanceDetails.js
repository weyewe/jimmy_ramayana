Ext.define('AM.store.MaintenanceDetails', {
	extend: 'Ext.data.Store',
	require : ['AM.model.MaintenanceDetail'],
	model: 'AM.model.MaintenanceDetail',
	// autoLoad: {start: 0, limit: this.pageSize},
	autoLoad : false, 
	autoSync: false,
	pageSize : 10, 
	
	sorters : [
		{
			property	: 'id',
			direction	: 'DESC'
		}
	], 
	listeners: {

	} 
});
