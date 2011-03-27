// move all elements selected in the library to 0,0

fl.outputPanel.clear();
var trace = fl.trace;
fl.showIdleMessage(false);

var doc = fl.getDocumentDOM();
var lib = doc.library;


function main()
{
	var selItems = lib.getSelectedItems();

	for(var i = 0; i < selItems.length; i++)
	{
		var itm = selItems[i];
    	moveToTL(itm);
	}
}

function moveToTL(libElement)
{
	if(libElement.symbolType == "movie clip" || libElement.symbolType == "graphic")
	{
		lib.editItem(libElement.name);
		doc.selectAll();
		if(doc.selection.length > 0)
		{
			var sel = doc.selection[0];
			sel.x = sel.width / 2;
			sel.y = sel.height / 2;
		}
		doc.selectNone();
		doc.exitEditMode();
	}
}
function traceProps(obj)
{
    for(var o in obj)
    {
        trace(o);
        //var val = obj[o] != undefined ? obj[o] : "null";
        //var tp = obj[o] != undefined ? typeof(obj[o]) : "null";
        //trace(o + " : " + val + " :: " + tp);
    }
}
main();

