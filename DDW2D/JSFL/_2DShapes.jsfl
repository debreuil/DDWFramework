fl.outputPanel.clear();
var trace = fl.trace;
fl.showIdleMessage(false);
var doc = fl.getDocumentDOM();
var tl = fl.getDocumentDOM().getTimeline();
var firstGuideLayer = null;

function main()
{
	var guideLayers = getGuideLayers();
	var bodyOutlines = getBodyOutlines(guideLayers);
	addPointMarkers(bodyOutlines);

	var ptIndex = tl.findLayerIndex("2D Points");
	tl.layers[ptIndex].locked = true;
}

function addPointMarkers(outlines)
{
	ensure2DLibrary();
	ensureClearPointLayer();
	var el;
	for(shapes = 0; shapes < outlines.length; shapes++)
	{
		if(outlines[shapes].isCircle)
		{
			doc.selectNone();
			var cent = outlines[shapes][0];
			var radius = outlines[shapes][1];
			doc.library.addItemToDocument(cent, "Box2D Joints/circleShape");
			el = doc.selection[0];

			el.x = cent.x;
			el.y = cent.y;
			el.scaleX = radius / 50.0;
			el.scaleY = radius / 50.0;
			el.name = "p$" + shapes + "_" + 0;
		}
		else
		{
			for(var i = 0; i < outlines[shapes].length; i++)
			{
				doc.selectNone();
				var pt = outlines[shapes][i];
				doc.library.addItemToDocument(pt, "Box2D Joints/point2D");
				el = doc.selection[0];
				el.name = "p$" + shapes + "_" + i;
			}
		}
	}
}

function ensureClearPointLayer(outlines)
{
	if(firstGuideLayer != null)
	{
		var layerIndex = tl.findLayerIndex("2D Points");
		layerIndex = layerIndex == null ? null : parseInt(layerIndex);
		if(layerIndex != null)
		{
			tl.deleteLayer(layerIndex);
		}

		var fgIndex = tl.findLayerIndex(firstGuideLayer.name);
		tl.setSelectedLayers(parseInt(fgIndex));

		tl.addNewLayer("2D Points", "normal", true);

		var ptIndex = tl.findLayerIndex("2D Points");
		tl.setSelectedLayers(parseInt(ptIndex));
		tl.layers[ptIndex].locked = false;
	}
}

function getBodyOutlines(guideLayers)
{
	var result = [];
	for(var i = 0; i < guideLayers.length; i++)
	{
		var fr = guideLayers[i].frames[0];
		var polylines = findOutlineShapes(fr);
		result = result.concat(polylines);
	}
	return result;
}

function findOutlineShapes(frame, outlineList)
{
	doc.selectNone();
	var result = [];
	for(var i = 0; i < frame.elements.length; i++)
	{
		var el = frame.elements[i];
		if(el.elementType == "shape" && el.vertices.length > 2)
		{
			doc.selectNone();
			doc.selection = [el];
			var stroke = doc.getCustomStroke("selection");

			// note: isGroup bug, always is true here
			if(stroke.style == "noStroke")
			{
				doc.enterEditMode();
				doc.selectAll();
				stroke = doc.getCustomStroke("selection");
				doc.exitEditMode();
			}

			if(stroke.color != null && stroke.color.toUpperCase() == "#FF0000" && stroke.thickness <= 1)
			{
				var polyline = parseHalfEdges(el.edges[0]);
				polyline.isCircle = false;
				if(el.isOvalObject)
				{
					// use center/radius for now
					// todo: accommodate ovals
					trace(el.x);
					var radius = el.width / 2;
					var cent = {x:el.x, y:el.y};
					var oval = [cent, radius];
					oval.isCircle = true;
					result.push(oval);
				}
				else
				{
					result.push(polyline);
				}
			}
		}
	}
	doc.selectNone();
	return result;
}


function getGuideLayers()
{
	var result = [];
	for(var i = 0; i < tl.layerCount; i++)
	{
		var ly = tl.layers[i];
		if(ly.layerType == "guide")
		{
			if(firstGuideLayer == null)
			{
				firstGuideLayer = ly;
			}
			result.push(ly);
			ly.locked = false;
		}
	}
	return result;
}

function ensure2DLibrary()
{
	if(!doc.library.itemExists("Box2D Joints/circleShape"))
	{
		trace("Box2D Joints library is missing. Please add that folder to the library (source Markers2D.fla)");
	}
}

function parseHalfEdges(edge)
{
	var result;
	var segments = [];

	var he = edge.getHalfEdge(0);
	var orgVertexId = he.id;
	segments.push(getSegment(edge));
	var curVertex = null;
	while(he != null)
	{
		he = he.getNext();
		if(he.id == orgVertexId)
		{
			break;
		}
		segments.push(getSegment(he.getEdge()));
	}

	var t2t = getTipToTail(segments);

	var result = getPointsFromSegments(t2t);

	ensureCW(result);

	return result;
}

function ensureCW(pts)
{
	if(pts.length > 2)
	{
		var cp =
			(pts[1].x - pts[0].x) *
			(pts[2].y - pts[1].y) -
			(pts[1].y - pts[0].y) *
			(pts[2].x - pts[1].x);

		var isCW = (cp > 0);

		if(!isCW)
		{
			pts = pts.reverse();
		}
	}
}

function getPointsFromSegments(segs)
{
	result = [];
	for(var i = 0; i < segs.length; i++)
	{
		result.push(segs[i][0]);
	}
	return result;
}

function getSegment(edge)
{
	var result = [];
	result.push(edge.getControl(0));
	result.push(edge.getControl(2));
	return result;
}

function getTipToTail(ar)
{
	var result = [];
	if(ar.length > 0)
	{
		var hasMatch = true;
		curPoint = ar[0];
		ar.splice(0, 1);
		result.push(curPoint);
		while(ar.length != 0 && hasMatch)
		{
			hasMatch = false;
			for(var i = 0; i < ar.length; i++)
			{
				var seg = formsSegment(curPoint, ar[i]);
				if(seg != null)
				{
					curPoint = seg;
					result.push(curPoint);
					ar.splice(i, 1);
					hasMatch = true;
					break;
				}
			}
		}
	}

	return result;
}

function formsSegment(prev, next)
{
	var result = null;
	if(prev[1].x == next[0].x && prev[1].y == next[0].y)
	{
		result = next;
	}
	else if(prev[1].x == next[1].x && prev[1].y == next[1].y)
	{
		result = [{x:next[1].x, y:next[1].y}, {x:next[0].x, y:next[0].y}];
	}
	return result;
}

function traceAll(obj, tab)
{
	tab = (tab == null) ? "" : tab;
	for(var o in obj)
	{
		if( typeof(obj[o]) == "object")
		{
			trace(tab + o);
			traceAll(obj[o], tab + "\t");
		}
		else
		{
			trace(tab + "" + o + ":" + obj[o]);
		}
	}
}
main();