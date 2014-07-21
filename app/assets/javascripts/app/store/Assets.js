Ext.define('AM.store.Assets', {
	extend: 'Ext.data.Store',
	require : ['AM.model.Asset'],
	model: 'AM.model.Asset',
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
