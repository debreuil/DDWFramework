// public domain, Robin Debreuil

// makes groups of cirlces (and reindexes) based on the instance root names.
// Selection of multiple groups allowed.
// eg. 20 objects with the root "square" and 15 with the root "circle"
// will make two circles.
// To change the center point between fixed, averaged, or weighted, look at the last lines.

fl.outputPanel.clear();
var trace = fl.trace;
fl.showIdleMessage(false);

// renames all elements to have zero based suffixes for common roots

var sel = fl.getDocumentDOM().selection;
trace("Count: " + sel.length);

var table = createNameTable(sel);
renameElements(sel, table);
for(var s in table)
{
	createCircle(table[s][1]);
}

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
		result[roots[i]] = [0, []];
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
				sel[i].name = "#" + rt + tbl[rt][0];
				tbl[rt][0]++;
				tbl[rt][1].push(sel[i])
			}
		}
	}
	for(var i = 0; i < sel.length; i++)
	{
		sel[i].name = sel[i].name.substring(1);
	}
}

function createCircle(elems, scale, cx, cy)
{
	var c = (scale == null) ? getCenter(elems) : {w:scale, h:scale, cx:cx, cy:cy};

	for(var i = 0; i < elems.length; i++)
	{
		var ang = (Math.PI * 2) / elems.length * i;
		elems[i].x = Math.sin(ang) * (c.w/2) + c.cx;
		elems[i].y = -Math.cos(ang) * (c.h/2) + c.cy;
		elems[i].rotation = ang * 180 / Math.PI;
		//trace(elems[i].left);
	}
}
function getCenter(elems)
{
	var result = {w:0, h:0, cx:0, cy:0};

	var mnx = Number.MAX_VALUE;
	var mny = Number.MAX_VALUE;
	var mxx = Number.MIN_VALUE;
	var mxy = Number.MIN_VALUE;
	var tx = 0;
	var ty = 0;

	for(var i = 0; i < elems.length; i++)
	{
		var e = elems[i];
		tx += e.x;
		ty += e.y;
		mnx = e.x < mnx ? e.x : mnx;
		mny = e.y < mny ? e.y : mny;
		mxx = e.x > mxx ? e.x : mxx;
		mxy = e.y > mxy ? e.y : mxy;
	}
	result.w = ( (mxx - mnx) + (mxy - mny) ) / 2;
	result.h = ( (mxx - mnx) + (mxy - mny) ) / 2;
	//result.cx = mnx + result.w / 2;//tx / elems.length;
	//result.cy = mny + result.h / 2;//ty / elems.length;
	// or set to fixed pos to help with alignment
	result.cx = 200;
	result.cy = 200;

	return result;
}







