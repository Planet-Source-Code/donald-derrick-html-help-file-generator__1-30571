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
	<OBJECT type="text/site properties">
		<param name="Window Styles" value="0x800025"/>
	</OBJECT>
	<UL>
		<LI>
			<OBJECT type="text/sitemap">
				<param name="Name" value="{PROJECT/@NAME}"/>
				<param name="Local" value="html\IDH_{PROJECT/@HELPCONTEXTID}.htm"/>
			</OBJECT>
		</LI>
		<UL>
			<xsl:for-each select="//PROJECT/SERVER">
			<LI>
				<OBJECT type="text/sitemap">
					<param name="Name" value="{@NAME}"/>
					<param name="New" value="1"/>
					<param name="ImageNumber" value="1"/>
				</OBJECT>
			</LI>
			<UL>
				<LI>
					<OBJECT type="text/sitemap">
						<param name="Name" value="Collections"/>
						<param name="New" value="1"/>
						<param name="ImageNumber" value="1"/>
					</OBJECT>
				</LI>
				<UL>
					<xsl:for-each select="COLLECTIONS/COLLECTION">
					<LI>
						<OBJECT type="text/sitemap">
							<param name="Name" value="{@NAME}"/>
							<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
						</OBJECT>
					</LI>
					</xsl:for-each>
				</UL>
				<LI>
					<OBJECT type="text/sitemap">
						<param name="Name" value="Enums"/>
						<param name="New" value="1"/>
						<param name="ImageNumber" value="1"/>
					</OBJECT>
				</LI>
				<UL>
					<xsl:for-each select="ENUMS/ENUM">
					<LI>
						<OBJECT type="text/sitemap">
							<param name="Name" value="{@NAME}"/>
							<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
						</OBJECT>
					</LI>
					</xsl:for-each>
				</UL>

			</UL>
			<UL>
				<xsl:for-each select="INTERFACES/INTERFACE">
				<LI>
					<OBJECT type="text/sitemap">
						<param name="Name" value="{@NAME}"/>
						<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
					</OBJECT>
				</LI>
				<UL>
					<xsl:if test="MEMBERS/MEMBER[(@INVOKEKIND='Function' or @INVOKEKIND='Sub')]">
					<LI>
						<OBJECT type="text/sitemap">
							<param name="Name" value="Methods"/>
							<param name="New" value="1"/>
							<param name="ImageNumber" value="1"/>
						</OBJECT>
					</LI>
					<UL>
						<xsl:for-each select="MEMBERS/MEMBER[(@INVOKEKIND='Function' or @INVOKEKIND='Sub') and (generate-id()=generate-id(key('distinct-helpcontextid',@HELPCONTEXTID)[1]))]">
							<LI>
								<OBJECT type="text/sitemap">
									<param name="Name" value="{@NAME}"/>
									<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
								</OBJECT>
							</LI>
						</xsl:for-each>
					</UL>
					</xsl:if>
					<xsl:if test="MEMBERS/MEMBER[(@INVOKEKIND='Event')]">
					<LI>
						<OBJECT type="text/sitemap">
							<param name="Name" value="Events"/>
							<param name="New" value="1"/>
							<param name="ImageNumber" value="1"/>
						</OBJECT>
					</LI>
					<UL>
						<xsl:for-each select="MEMBERS/MEMBER[(@INVOKEKIND='Event') and (generate-id()=generate-id(key('distinct-helpcontextid',@HELPCONTEXTID)[1]))]">
							<LI>
								<OBJECT type="text/sitemap">
									<param name="Name" value="{@NAME}"/>
									<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
								</OBJECT>
							</LI>
						</xsl:for-each>
					</UL>
					</xsl:if>
					<xsl:if test="MEMBERS/MEMBER[(@INVOKEKIND='Property Get' or @INVOKEKIND='Property Let' or @INVOKEKIND='Property Set')]">
					<LI>
						<OBJECT type="text/sitemap">
							<param name="Name" value="Properties"/>
							<param name="New" value="1"/>
							<param name="ImageNumber" value="1"/>
						</OBJECT>
					</LI>
					<UL>
						<xsl:for-each select="MEMBERS/MEMBER[(@INVOKEKIND='Property Get' or @INVOKEKIND='Property Let' or @INVOKEKIND='Property Set') and (generate-id()=generate-id(key('distinct-helpcontextid',@HELPCONTEXTID)[1]))]">
							<LI>
								<OBJECT type="text/sitemap">
									<param name="Name" value="{@NAME}"/>
									<param name="Local" value="html\IDH_{@HELPCONTEXTID}.htm"/>
								</OBJECT>
							</LI>
						</xsl:for-each>
					</UL>
					</xsl:if>
				</UL>
				</xsl:for-each>
			</UL>
			</xsl:for-each>
		</UL>
	</UL>
</BODY>
</HTML>
</xsl:template>
</xsl:stylesheet>