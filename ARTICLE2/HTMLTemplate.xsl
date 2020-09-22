<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:template match="/">
<HTML>
<LINK rel="stylesheet" type="text/css" href="typelib.css"/>
<SCRIPT language="javascript" src="typelibFunctions.js">
</SCRIPT>
<SCRIPT language="javascript">
function windowOnLoad()
{
transform(<xsl:value-of select="PROJECT/@FILTERHELPCONTEXTID"/>)
}
</SCRIPT>
<BODY LANGUAGE="javascript" onload="return windowOnLoad()">
</BODY>

</HTML>
</xsl:template>
</xsl:stylesheet>