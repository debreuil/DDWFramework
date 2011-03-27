
var lib = fl.getDocumentDOM().library;

var selItems = lib.getSelectedItems();
for(var i = 0; i < selItems.length; i++)
{
	var itm = selItems[i];

	itm.allowSmoothing = true;
	itm.compressionType = 'photo';

}