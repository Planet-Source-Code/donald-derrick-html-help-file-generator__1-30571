<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method = "html"/>
<xsl:key name="distinct-helpcontextid" match="*//@HELPCONTEXTID" use="."/>
<xsl:template match="/">
[OPTIONS]
Compatibility=1.1 or later
Compiled file=<xsl:value-of select="PROJECT/@NAME"/>.chm
Contents file=TableOfContents.hhc
Default topic=html\IDH_<xsl:value-of select="PROJECT/@HELPCONTEXTID"/>.htm
Display compile progress=No
Full-Text Search=No
Index file=Index.hhk
Language=0x409 English (United States)
Title=<xsl:value-of select="PROJECT/@NAME"/>

[FILES]
<xsl:for-each select="*//@HELPCONTEXTID[(generate-id()=generate-id(key('distinct-helpcontextid',.)[1]))]">
html\IDH_<xsl:value-of select="."/>.htm
</xsl:for-each>
html\typelib.xml
html\typelib.xsl
html\typelibfunctions.js
html\typelib.css
html\downarrow.gif
html\rightarrow.gif

[ALIAS]
<xsl:for-each select="*//@HELPCONTEXTID[(generate-id()=generate-id(key('distinct-helpcontextid',.)[1]))]">
IDH_<xsl:value-of select="."/>=html\IDH_<xsl:value-of select="."/>.htm
</xsl:for-each>

[MAP]
#include header.h

[INFOTYPES]
</xsl:template>
</xsl:stylesheet>