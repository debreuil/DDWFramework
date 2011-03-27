// public domain, Robin Debreuil

// renumbers elements respecting their roots
// selection of multiple groups allowed.
// eg. 20 objects with the root "square" and 15 with the root "circle"
// will reindex the two sets.

fl.outputPanel.clear();
var trace = fl.trace;
fl.showIdleMessage(false);

// renames all elements to have zero based suffixes for common roots

var table = createNameTable(fl.getDocumentDOM().selection);
renameElements(fl.getDocumentDOM().selection, table);

function createNameTable(sel)
{
	var result = {};
	var names = [];
	var nameRoots = "#";
	var lastRoot = "";
	for(var i = 0; i < sel.length; i++)
	{
		var n = sel[i].name;
		names.push(n);
		var s = n.match(/[^0-9]*/gi)[0];
		if(s != "" && nameRoots.indexOf("#" + s + "#") < 0)
		{
			nameRoots += s + "#";
			lastRoot = s;
		}
	}
	nameRoots = nameRoots.substring(1, nameRoots.length - 1);
	var roots = nameRoots.split("#");
	roots.sort(function(a,b){return b.length - a.length});

	for(var i = 0; i < roots.length; i++)
	{
		result[roots[i]] = 0;
	}
	return result;
}

function renameElements(sel, tbl)
{
	for(var rt in tbl)
	{
		for(var i = 0; i < sel.length; i++)
		{
			var n = sel[i].name;
			if(n.indexOf(rt) == 0 || n == "")
			{
				sel[i].name = "#" + rt + tbl[rt];
				tbl[rt]++;
			}
		}
	}
	for(var i = 0; i < sel.length; i++)
	{
		sel[i].name = sel[i].name.substring(1);
		trace(sel[i].name);
	}
}

