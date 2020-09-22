<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method = "html"/>
<xsl:key name="distinct-helpcontextid" match="*" use="@HELPCONTEXTID"/>
<xsl:template match="/">
<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"&gt;</xsl:text>
<HTML>
<HEAD>
<meta name="GENERATOR" content="Donald Derrick's AutoDoc 2001"/>
</HEAD>
<BODY>
		<UL>
			<xsl:for-each select="//PROJECT/SERVER">
			<LI>
				<OBJECT type="text/sitemap">
					<param name="Name" value="{@NAME}"/>
					<param name="Name" value="Untitled: html\IDH_{@HELPCONTEXTID}.htm"/>
					<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
				</OBJECT>
			</LI>
			<UL>
				<LI>
					<OBJECT type="text/sitemap">
						<param name="Name" value="Collections"/>
						<param name="New" value="1"/>
					</OBJECT>
				</LI>
			</UL>
			<UL>
				<xsl:for-each select="INTERFACES/INTERFACE">
				<LI>
					<OBJECT type="text/sitemap">
								<param name="Name" value="{@NAME}"/>
								<param name="Name" value="Untitled: html\IDH_{@HELPCONTEXTID}.htm"/>
								<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
					</OBJECT>
				</LI>
				<UL>
					<xsl:if test="MEMBERS/MEMBER[(@INVOKEKIND='Function' or @INVOKEKIND='Sub')]">
						<xsl:for-each select="MEMBERS/MEMBER[(@INVOKEKIND='Function' or @INVOKEKIND='Sub') and (generate-id()=generate-id(key('distinct-helpcontextid',@HELPCONTEXTID)[1]))]">
							<LI>
								<OBJECT type="text/sitemap">
									<param name="Name" value="{@NAME}"/>
									<param name="Name" value="Untitled: html\IDH_{@HELPCONTEXTID}.htm"/>
									<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
								</OBJECT>
							</LI>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="MEMBERS/MEMBER[(@INVOKEKIND='Event')]">
						<xsl:for-each select="MEMBERS/MEMBER[(@INVOKEKIND='Event') and (generate-id()=generate-id(key('distinct-helpcontextid',@HELPCONTEXTID)[1]))]">
							<LI>
								<OBJECT type="text/sitemap">
									<param name="Name" value="{@NAME}"/>
									<param name="Name" value="Untitled: html\IDH_{@HELPCONTEXTID}.htm"/>
									<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
								</OBJECT>
							</LI>
						</xsl:for-each>
					</xsl:if>
					<xsl:if test="MEMBERS/MEMBER[(@INVOKEKIND='Property Get' or @INVOKEKIND='Property Let' or @INVOKEKIND='Property Set')]">
						<xsl:for-each select="MEMBERS/MEMBER[(@INVOKEKIND='Property Get' or @INVOKEKIND='Property Let' or @INVOKEKIND='Property Set') and (generate-id()=generate-id(key('distinct-helpcontextid',@HELPCONTEXTID)[1]))]">
							<LI>
								<OBJECT type="text/sitemap">
									<param name="Name" value="{@NAME}"/>
									<param name="Name" value="Untitled: html\IDH_{@HELPCONTEXTID}.htm"/>
									<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
								</OBJECT>
							</LI>
						</xsl:for-each>
					</xsl:if>
				</UL>
				</xsl:for-each>
			</UL>
			<UL>
				<LI>
					<OBJECT type="text/sitemap">
						<param name="Name" value="Enums"/>
						<param name="New" value="1"/>
					</OBJECT>
				</LI>
				<xsl:for-each select="ENUMS/ENUM">
					<LI>
						<OBJECT type="text/sitemap">
							<param name="Name" value="{@NAME}"/>
							<param name="Name" value="Untitled: html\IDH_{@HELPCONTEXTID}.htm"/>
							<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
						</OBJECT>
					</LI>
				</xsl:for-each>
			</UL>
		</xsl:for-each>
	</UL>
</BODY>
</HTML>
</xsl:template>
</xsl:stylesheet>