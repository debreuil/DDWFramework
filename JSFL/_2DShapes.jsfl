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
		var ptName = (outlines[shapes].isSpline) ? "sp$" : "p$";
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
			el.name = ptName + shapes + "_" + 0;
		}
		else
		{
			for(var i = 0; i < outlines[shapes].length; i++)
			{
				doc.selectNone();
				var pt = outlines[shapes][i];
				doc.library.addItemToDocument(pt, "Box2D Joints/point2D");
				el = doc.selection[0];
				el.name = ptName + shapes + "_" + i;
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
	var shapesResult = [];
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
				var isSpline = true;
				for(var i = 0; i < el.contours.length; i++)
				{
					if(el.contours[i].interior)
					{
						isSpline = false;
						break;
					}
				}

				if(el.isOvalObject)
				{
					// use center/radius for now
					// todo: accommodate ovals
					var radius = el.width / 2;
					var cent = {x:el.x, y:el.y};
					var oval = [cent, radius];
					oval.isCircle = true;
					oval.isSpline = false;
					shapesResult.push(oval);
				}
				else if(isSpline)
				{
					var spline = parseSpline(el.edges[0]);
					spline.isCircle = false;
					spline.isSpline = true;
					shapesResult.push(spline);
				}
				else
				{
					var polyline = parseHalfEdges(el.edges[0]);
					polyline.isCircle = false;
					polyline.isSpline = false;
					shapesResult.push(polyline);
				}
			}
		}
	}
	var xx = shapesResult.slice(0);
	doc.selectNone();
	return shapesResult;
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

function parseSpline(edge)
{
	var points = [];

	var he = edge.getHalfEdge(0);
	var orgVertexId = he.id;
	var firstHe = null;
	var lastHe = null;

	// find first edge
	var prevHe = he;
	var passes = 0;
	var forward = false;;
	while(he != null)
	{
		he = forward ? he.getNext() : he.getPrev();
		var nextVertex = forward ? he.getNext().getVertex() : he.getPrev().getVertex();

		if(he.id == orgVertexId)
		{
			passes++;
			if(passes > 2)
			{
				trace("error: unclosed loop that is not a single spline");
				break;
			}
		}

		if(nextVertex.x == prevHe.getVertex().x && nextVertex.y == prevHe.getVertex().y)
		{
			if(firstHe == null)
			{
				firstHe = he;
				he = he.getNext();
				prevHe = he;
				forward = true;
			}
			else
			{
				lastHe = he;
				break;
			}
		}
		else
		{
			prevHe = he;
		}
	}
	he = firstHe;

	points.push(getPoint(he.getVertex()));

	while(he != null)
	{
		he = he.getNext();
		points.push(getPoint(he.getVertex()));
		if(he.id == lastHe.id)
		{
			break;
		}
	}

	return points;
}

function parseHalfEdges(edge)
{
	var result;
	var segments = [];

	var he = edge.getHalfEdge(0);
	var orgVertexId = he.id;
	segments.push(getSegment(he.getEdge()));
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
	result = getPointsFromSegments(t2t);

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
	var result = [];
	for(var i = 0; i < segs.length; i++)
	{
		result.push(segs[i][0]);
	}
	return result;
}

function getPoint(vertex)
{
	var result = {x:vertex.x, y:vertex.y};
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