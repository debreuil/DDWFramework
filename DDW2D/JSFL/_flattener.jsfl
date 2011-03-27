fl.outputPanel.clear();
var trace = fl.trace;
fl.showIdleMessage(false);

var doc = fl.getDocumentDOM();
var alphaStack = [];
var alphaPercent = 100;

function main()
{
    orgSel = doc.selection;
    flatten(doc.selection);    
}

function flatten(els)
{	
    for (var i = els.length - 1; i>=0; i--) 
    {	
        var e = els[i];
        if(e.elementType != "shape" || e.isGroup || e.isDrawingObject)
        {	
            alphaStack.push(alphaPercent);
            if(e.colorAplhaPercent != 100)
            {
                alphaPercent *=  e.colorAlphaPercent / 100;
            }
            
            if(!e.isDrawingObject)
            {
                doc.selectNone();
                doc.selection = [e];
                doc.enterEditMode("inPlace"); 
                
                doc.selectNone();
                doc.selectAll();    
                if(doc.selection.length > 0)
                {
                    flatten(doc.selection);
                }
                
                doc.exitEditMode();
            }
                     
            doc.selectNone();
            doc.selection = [e];
            doc.breakApart();
            
            setSelectedAlpha(alphaPercent);
            
            alphaPercent = alphaStack.pop();   
        }
        else if(e.isGroup || e.isDrawingObject)
        {
            doc.selectNone();
            doc.selection = [e];
            doc.breakApart();
        }
    }
}
function setSelectedAlpha(a)
{
    if(a < 100)
    {
        var fill = fl.getDocumentDOM().getCustomFill(); 
        var c = fill.color.substring(0, 7);
        var al = Math.floor(a/100 * 255).toString(16);
        
        fill.color = c + al;
        trace(c + al);
        fl.getDocumentDOM().setCustomFill(fill);
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

