
var lib = fl.getDocumentDOM().library;
var selItems = lib.getSelectedItems();

for(var i = 0; i < selItems.length; i++)
{
	var itm = selItems[i];
	var s = itm.name;
	if(s.indexOf("/") > -1)
	{
		s = s.substring(s.indexOf("/") + 1);
	}
	if(s.indexOf('.') > -1)
	{
		s = s.substring(0, s.indexOf('.'));
	}
	var re = /^(\D)(\D*)(\d*)$/;
	var ar = re.exec(s);


	//itm.name = "prop" + (parseInt(ar[2], 10) - 3);
	itm.name = ar[1] + ar[2] + parseInt(ar[3], 10);

	itm.linkageExportForAS = true;
	itm.linkageIdentifier = ar[1].toUpperCase() + ar[2] + parseInt(ar[3], 10);
	itm.linkageExportInFirstFrame = true;

	fl.trace(itm.name + " : " + itm.linkageIdentifier);

	//itm.linkageClassName = '';
	//itm.linkageImportForRS = false;
	//itm.scalingGrid = false;
}

