Ext.define('AM.store.Contacts', {
	extend: 'Ext.data.Store',
	require : ['AM.model.Contact'],
	model: 'AM.model.Contact',
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
