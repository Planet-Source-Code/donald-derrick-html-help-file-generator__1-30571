function transform(helpContextID)
{
var doc = new ActiveXObject("MSXML2.DOMDocument.3.0");
var stylesheet = new ActiveXObject("MSXML2.DOMDocument.3.0");

stylesheet.resolveExternals=false;
stylesheet.validateOnParse=false;
stylesheet.async = false;
stylesheet.load("typelib.xsl");

doc.resolveExternals=false;
doc.validateOnParse=false;
doc.async = false;
doc.load("typelib.xml");
doc.selectSingleNode("PROJECT").attributes.getNamedItem("FILTERHELPCONTEXTID").nodeValue = helpContextID;
document.write(doc.transformNode(stylesheet));
doc = null;
stylesheet = null;
}