<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:key name="distinct-method" match="PROJECT/SERVER/INTERFACES/INTERFACE[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]/MEMBERS/MEMBER[@INVOKEKIND='Function' or @INVOKEKIND='Sub']" use="@NAME"/>
<xsl:key name="distinct-event" match="PROJECT/SERVER/INTERFACES/INTERFACE[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]/MEMBERS/MEMBER[@INVOKEKIND='Event']" use="@NAME"/>
<xsl:key name="distinct-property" match="PROJECT/SERVER/INTERFACES/INTERFACE[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]/MEMBERS/MEMBER[(@INVOKEKIND='Property Get' or @INVOKEKIND='Property Let' or @INVOKEKIND='Property Set')]" use="@NAME"/>
<xsl:key name="distinct-name" match="PROJECT/SERVER/INTERFACES/INTERFACE/MEMBERS/MEMBER[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]" use="@NAME"/>
	<xsl:template match="/">
		<HTML>
			<LINK rel="stylesheet" type="text/css" href="typelib.css"/>
			<TITLE>
				Help Screen
			</TITLE>
			<SCRIPT language="javascript">
			<xsl:comment>
			<![CDATA[
				function ToggleDisplay(src, image)
				{
					if((src.style.display == '') || (src.style.display == 'none'))
					{
						src.style.display = 'block';
						image.src = 'downarrow.gif';
					}
					else
					{
						src.style.display = 'none';
						image.src = 'rightarrow.gif';
					}
				}
				function mOvr(src)
				{
					if (!src.contains(event.fromElement))
					{
						src.style.cursor = 'hand';
					}
				}
				function mOut(src)
				{
					if (!src.contains(event.toElement))
					{
						src.style.cursor = 'default';
					}
				}
				function Void()
				{
				}
				]]>
				</xsl:comment>
			</SCRIPT>
			<BODY>
				<xsl:apply-templates />
			</BODY>
		</HTML>
	</xsl:template>

	<xsl:template match="PROJECT[@HELPCONTEXTID=@FILTERHELPCONTEXTID]">
		<TABLE id="project">
			<TR>
				<TH class="header">
					Project Name
				</TH>
			</TR>
			<TR>
				<TD>
					<xsl:value-of select="@NAME"/>
				</TD>
			</TR>
		</TABLE>
		<xsl:for-each select="SERVER">
		<TABLE id="servers">
			<TR>
				<TH class="header">
					Server Name
				</TH>
			</TR>
			<TR>
				<TD>
					<xsl:value-of select="@NAME"/>
				</TD>
			</TR>
		</TABLE>
		<BR></BR>
		<TABLE id="serverdescriptionheader">
			<TR>
				<TH>
					<xsl:value-of select="@HELPSTRING"/>
				</TH>
			</TR>
			<TR>
				<TD>
					<xsl:value-of select="@DESCRIPTIONHEADER"/>
				</TD>
			</TR>
		</TABLE>
			<xsl:apply-templates/>
		<BR></BR>
		<TABLE id="serverdescriptionfooter">
			<TR>
				<TH class="header">
					Footnote:
				</TH>
			</TR>
			<TR>
				<TD>
					<xsl:value-of select="@DESCRIPTIONFOOTER"/>
				</TD>
			</TR>
		</TABLE>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="PROJECT/SERVER[(@HELPCONTEXTID)=/PROJECT/@FILTERHELPCONTEXTID]">
		<TABLE id="server">
			<TR>
				<TH class="header">
					Selected Automation Server
				</TH>
				<TH>
					Description
				</TH>
			</TR>
			<TR>
				<TD>
					<xsl:value-of select="@NAME"/>
				</TD>
				<TD>
					<xsl:choose>
						<xsl:when test="@DESCRIPTION!=''">
							<xsl:value-of select="@DESCRIPTION"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@HELPSTRING"/>
						</xsl:otherwise>
					</xsl:choose>
				</TD>
			</TR>
		</TABLE>

		<TABLE id="collectionheader">
			<TR>
				<TH class="header">
					<A HREF="javascript:Void();" onclick="ToggleDisplay(collection, collectionheaderimg);"><img src="rightarrow.gif" id="collectionheaderimg" border="0"/>
					Collection
					</A>
				</TH>
			</TR>
		</TABLE>


		<TABLE id="collection">
		<SCRIPT>collection.style.display='none';</SCRIPT>
			<TR>
				<TH class="header">
					Class
				</TH>
				<TH>
					Description
				</TH>
			</TR>
			<xsl:for-each select="COLLECTIONS/COLLECTION">
				<TR>
					<TD>
						<xsl:value-of select="@NAME"/>
					</TD>
					<TD>
						<xsl:choose>
							<xsl:when test="@DESCRIPTION!=''">
								<xsl:value-of select="@DESCRIPTION"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@HELPSTRING"/>
							</xsl:otherwise>
						</xsl:choose>
					</TD>
				</TR>
			</xsl:for-each>
		</TABLE>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="PROJECT/SERVER/INTERFACES/INTERFACE[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]">
		<TABLE id="interfaces">
			<TR>
				<TH class="header">
					Interface Name
				</TH>
			</TR>
			<TR>
				<TD>
					<xsl:value-of select="@NAME"/>
				</TD>
			</TR>
			<TR>
				<TD>
					<xsl:value-of select="@HELPSTRING"/>
				</TD>
			</TR>

		</TABLE>
		<TABLE id="members">
			<TR>
				<TH>
					<A HREF="javascript:Void();" ONCLICK="ToggleDisplay(imethods, methodsimg);"><img src="rightarrow.gif" id="methodsimg" border="0"/>
					Methods
					</A>
				</TH>
				<TH>
					<A HREF="javascript:Void();" ONCLICK="ToggleDisplay(ievents, eventsimg);"><img src="rightarrow.gif" id="eventsimg" border="0"/>
					Events
					</A>
				</TH>
				<TH>
					<A HREF="javascript:Void();" ONCLICK="ToggleDisplay(iproperties, propertiesimg);"><img src="rightarrow.gif" id="propertiesimg" border="0"/>
					Properties
					</A>
				</TH>
			</TR>
			<TR>
				<TD>
					<DIV id="imethods"><SCRIPT>imethods.style.display='none';</SCRIPT>
						<TABLE id="methods">
							<xsl:for-each select="//PROJECT/SERVER/INTERFACES/INTERFACE[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]/MEMBERS/MEMBER[(@INVOKEKIND='Function' or @INVOKEKIND='Sub') and (generate-id()=generate-id(key('distinct-method',@NAME)[1]))]">
								<xsl:sort select="@NAME"/>
								<TR>
									<TD>
										<xsl:value-of select="@NAME"/>
									</TD>
								</TR>
							</xsl:for-each>
						</TABLE>
					</DIV>
				</TD>
				<TD>
					<DIV id="ievents"><SCRIPT>ievents.style.display='none';</SCRIPT>
						<TABLE id="events">
							<xsl:for-each select="//PROJECT/SERVER/INTERFACES/INTERFACE[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]/MEMBERS/MEMBER[(@INVOKEKIND='Event') and (generate-id()=generate-id(key('distinct-event',@NAME)[1]))]">
								<xsl:sort select="@NAME"/>
								<TR>
									<TD>
										<xsl:value-of select="@NAME"/>
									</TD>
								</TR>
							</xsl:for-each>
						</TABLE>
					</DIV>
				</TD>
				<TD>
					<DIV id="iproperties"><SCRIPT>iproperties.style.display='none';</SCRIPT>
						<TABLE id="properties">
							<xsl:for-each select="//PROJECT/SERVER/INTERFACES/INTERFACE[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]/MEMBERS/MEMBER[(@INVOKEKIND='Property Get' or @INVOKEKIND='Property Let' or @INVOKEKIND='Property Set') and (generate-id()=generate-id(key('distinct-property',@NAME)[1]))]">
								<xsl:sort select="@NAME"/>
								<TR>
									<TD>
										<xsl:value-of select="@NAME"/>
									</TD>
								</TR>
							</xsl:for-each>
						</TABLE>
					</DIV>
				</TD>
			</TR>
		</TABLE>
	</xsl:template>
	<xsl:template match="PROJECT/SERVER/INTERFACES/INTERFACE/MEMBERS/MEMBER[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID and (generate-id()=generate-id(key('distinct-name',@NAME)[1]))]">
			<TABLE id="member">
				<TR>
					<TH class="header">
					<xsl:choose>
						<xsl:when test="@INVOKEKIND='Function' or @INVOKEKIND='Sub'">
							Method
						</xsl:when>
						<xsl:when test="@INVOKEKIND='Event'">
							Event
						</xsl:when>
						<xsl:when test="@INVOKEKIND='Property Get' or @INVOKEKIND='Property Let' or @INVOKEKIND='Property Set'">
							Property
						</xsl:when>
					</xsl:choose>
					</TH>
				</TR>
				<TR>
					<TH>
						<xsl:value-of select="@NAME"/>
					</TH>
				</TR>
				<TR>
					<TD>
						<xsl:value-of select="@HELPSTRING"/>
					</TD>
				</TR>

				<TR>
					<TD>
						<xsl:value-of select="@DESCRIPTION"/>
					</TD>
				</TR>

			</TABLE>

			<TABLE id="syntax">
			<TR>
				<TH class="header">
					Syntax
				</TH>
			</TR>
			<xsl:for-each select="//PROJECT/SERVER/INTERFACES/INTERFACE/MEMBERS/MEMBER[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]">
				<TR>
					<TH class="header">
						<xsl:value-of select="@INVOKEKIND"/>
					</TH>
				</TR>
				<TR>
					<TH>
						<xsl:value-of disable-output-escaping="yes" select="@STRING"/>
					</TH>
				</TR>
			</xsl:for-each>
			</TABLE>
			<BR></BR>
			<TABLE id="parametersheader">
				<TR>
					<TH class="header">
						Parameters
					</TH>
				</TR>
			</TABLE>

			<BR></BR>

			<TABLE id="parameters">
				<TR>
					<TH class="header">
						Parameter
					</TH>
					<TH class="header">
						Type
					</TH>
					<TH class="header">
						Description
					</TH>
				</TR>
				<xsl:for-each select="PARAMETERS/PARAMETER">
					<TR>
						<TD>
							<xsl:value-of select="@NAME"/>
						</TD>
						<TD>
							<xsl:value-of select="@VARTYPEINFO"/>
						</TD>
						<TD>
							<xsl:value-of select="@DESCRIPTION"/>
						</TD>
					</TR>
				</xsl:for-each>
			</TABLE>
	</xsl:template>
	<xsl:template match="PROJECT/SERVER/ENUMS/ENUM[@HELPCONTEXTID=/PROJECT/@FILTERHELPCONTEXTID]">
		<TABLE id="enum">
			<TR>
				<TH>
				Enum Name: 
				</TH>
				<TH>
					<xsl:value-of select="@NAME"/>
				</TH>
			</TR>
			<TR>
				<TH>
					Constant Name:
				</TH>
				<TH>
					Value:
				</TH>
				<TH>
					Description:
				</TH>	
			</TR>
			<xsl:for-each select="CONSTANTS/CONSTANT">
				<TR>
					<TD>
						<xsl:value-of select="@NAME"/>
					</TD>
					<TD>
						<xsl:value-of select="@VALUE"/>
					</TD>
					<TD>
						<xsl:value-of select="@DESCRIPTION"/>
					</TD>
				</TR>
			</xsl:for-each>
		</TABLE>
	</xsl:template>

</xsl:stylesheet>