<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method = "html"/>
<xsl:key name="distinct-helpcontextid" match="*//@HELPCONTEXTID" use="."/>
<xsl:template match="/">
<xsl:for-each select="*//@HELPCONTEXTID[(generate-id()=generate-id(key('distinct-helpcontextid',.)[1]))]">
#define IDH_<xsl:value-of select="."/><xsl:text> </xsl:text><xsl:value-of select="."/>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>