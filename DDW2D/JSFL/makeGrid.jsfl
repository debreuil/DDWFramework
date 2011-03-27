// public domain, Robin Debreuil

// makes groups of grids in place (and reindexes) based on the w/h and instance root names.
// Selection of multiple groups allowed.
// eg. 20 objects with the root "square" and 15 with the root "circle"
// will make two grids, one of circles and one of squares.
// To change the center point between fixed, averaged, or weighted, look at the last lines

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
	createGrid(table[s][1]);
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
		var s = n.match(/[^0-9_]*/gi)[0];
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
				sel[i].name = "#" + rt;
				tbl[rt][0]++;
				tbl[rt][1].push(sel[i])
			}
		}
	}
	for(var i = 0; i < sel.length; i++)
	{
		sel[i].name = sel[i].name.substring(1);
	}

	for(var rt in tbl)
	{
		var group = tbl[rt][1];
		getCenter(group);
		for(var i = 0; i < group.length; i++)
		{
			var txt = "_" + (i % across) + "_" + Math.floor(i / across);
			group[i].name += txt;
		}
	}
}
var ratio;
var count;
var down;
var across;

function createGrid(elems, size, cx, cy)
{
	var c = (size == null) ? getCenter(elems) : {w:size, h:size, cx:cx, cy:cy};

	var ew = elems[0].width;
	var eh = elems[0].height;
	var spcX = (c.w - across * ew) / across;
	var spcY = (c.h - down * eh) / down;
	var offsetX = c.cx - c.w / 2;
	var offsetY = c.cy - c.h / 2;

	for(var i = 0; i < elems.length; i++)
	{
		elems[i].x = (i % across) * (spcX + ew)  + offsetX;
		elems[i].y = Math.floor(i / across) * (spcY + eh) + offsetY;
		elems[i].rotation = 0;
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
	result.w = mxx - mnx + elems[0].width;
	result.h = mxy - mny + elems[0].height;
	result.cx = mnx + result.w / 2;//tx / elems.length;
	result.cy = mny + result.h / 2;//ty / elems.length;

	ratio = result.h / result.w;
	count = elems.length;
	across = Math.sqrt(count / ratio);
	down = Math.round(across * ratio);
	across = Math.round(across);

	return result;
}







