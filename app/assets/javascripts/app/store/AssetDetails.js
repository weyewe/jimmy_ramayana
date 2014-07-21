Ext.define('AM.store.AssetDetails', {
	extend: 'Ext.data.Store',
	require : ['AM.model.AssetDetail'],
	model: 'AM.model.AssetDetail',
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
