fl.outputPanel.clear();
var trace = fl.trace;
fl.showIdleMessage(false);

// remove instance names
renameElements(fl.getDocumentDOM().selection);

function renameElements(sel)
{
	for(var i = 0; i < sel.length; i++)
	{trace(sel[i].name);
		sel[i].name = "";
	}
}

