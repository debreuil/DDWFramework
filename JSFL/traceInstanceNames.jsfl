// public domain, Robin Debreuil

// renumbers elements respecting their roots
// selection of multiple groups allowed.
// eg. 20 objects with the root "square" and 15 with the root "circle"
// will reindex the two sets.

fl.outputPanel.clear();
var trace = fl.trace;
fl.showIdleMessage(false);

// renames all elements to have zero based suffixes for common roots

traceInstanceNames(fl.getDocumentDOM().selection);

function traceInstanceNames(sel)
{
	var names = [];
	for(var i = 0; i < sel.length; i++)
	{
		var n = sel[i].name;
		names.push(n);
	}
	names.sort();
	//roots.sort(function(a,b){return b.length - a.length});

	for(var i = 0; i < names.length; i++)
	{
		trace(names[i]);
	}
}
