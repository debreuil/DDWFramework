fl.outputPanel.clear();
var trace = fl.trace;
fl.showIdleMessage(false);

var runOnAllItems = true;
var runOnAllFiles = true;
var flashDocs = [];

var folderName = fl.getDocumentDOM().path;
folderName = folderName.substring(0, folderName.lastIndexOf("\\"));
folderName = folderName.replace(/\\/g, "/");
folderName = folderName.replace(/:/, "|");
folderName = "file:///" + folderName;


var cfDir = fl.configDirectory;
cfDir = cfDir.replace(/\\/g, "/");
cfDir = cfDir.replace(/:/, "|");
cfDir = "file:///" + cfDir;

 var exports;


function main()
{
	if(runOnAllFiles)
	{
		findAllFlaFiles(folderName);
		processAllFlaFiles();
	}
	else
	{
		processFla(fl.getDocumentDom());
	}
}

function findAllFlaFiles(dir)
{
	var files = FLfile.listFolder(dir + "/*.fla", "files");
	for(var f = 0; f < files.length; f++)
	{
		flashDocs.push(dir + "/" + files[f]);
	}

	var dirs = FLfile.listFolder(dir, "directories");
	if(dirs != null)
	{
		for(var i = 0; i < dirs.length; i++)
		{
			findAllFlaFiles(dir + "/" + dirs[i]);
		}
	}
}
function processAllFlaFiles()
{
	for(var i = 0; i < flashDocs.length; i++)
	{
		processFla(flashDocs[i]);
	}
}
function processFla(path)
{
	var doc = fl.openDocument(path);
	var lib = doc.library;

	if(runOnAllItems)
	{
		lib.selectAll();
		lib.expandFolder(true, true);
		lib.selectAll();
	}
	exports = null;
	exports = {};
	modifyDoc(doc);

	if(runOnAllItems)
	{
		lib.selectAll();
		lib.expandFolder(false, true);
		lib.selectNone();
	}
	fl.saveDocument(doc);
	doc.publish();

	//fl.outputPanel.save(folderName + "" + doc.name + ".contents");
	//fl.outputPanel.clear();
	fl.closeDocument(doc, false);
}
function modifyDoc(doc)
{
	var pp = cfDir + "Publish Profiles/jpgExport.xml";
	doc.importPublishProfile(pp);
	doc.currentPublishProfile = "jpgExport";
	return;
}


main();