Ext.define('AM.store.Compatibilities', {
	extend: 'Ext.data.Store',
	require : ['AM.model.Compatibility'],
	model: 'AM.model.Compatibility',
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
