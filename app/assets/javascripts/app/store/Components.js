Ext.define('AM.store.Components', {
	extend: 'Ext.data.Store',
	require : ['AM.model.Component'],
	model: 'AM.model.Component',
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
