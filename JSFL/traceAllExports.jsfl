
var lib = fl.getDocumentDOM().library;


function traceAllInFolder(folder)
{
	var itms = lib.selectAll();
	var selItems = lib.getSelectedItems();
	for(var i = 0; i < selItems.length; i++)
	{
		var itm = selItems[i];
		if(itm.linkageExportForAS == true)
		{fl.trace(itm);
			fl.trace(itm.linkageClassName);
		}
	}
}
traceAllInFolder();

