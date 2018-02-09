<?xml version="1.0" encoding="UTF-8"?>
<!-- gpx2kml.xsl: Copyright (C) 2013 anineco@nifty.com -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns="http://www.opengis.net/kml/2.2"
 xmlns:atom="http://www.w3.org/2005/Atom"
 xmlns:gpx="http://www.topografix.com/GPX/1/1"
 xmlns:kashmir3d="http://www.kashmir3d.com/namespace/kashmir3d"
 xmlns:date="http://exslt.org/dates-and-times"
 xmlns:exsl="http://exslt.org/common"
 xmlns:str="http://exslt.org/strings"
 xmlns:tmp="urn:tmp"
 extension-element-prefixes="date exsl str"
 exclude-result-prefixes="gpx kashmir3d tmp">
<xsl:output method="xml" encoding="UTF-8" indent="yes"
 cdata-section-elements="description"/>

<xsl:param name="VERSION">GPX2KML Ver.1.5</xsl:param>
<xsl:param name="ALPHA">b3</xsl:param>
<xsl:param name="ICONLUT">iconlut.xml</xsl:param>
<xsl:param name="iconlut" select="document($ICONLUT,/)/iconlut"/>

<xsl:variable name="tmp">
 <xsl:for-each select="//gpx:wpt//kashmir3d:icon|//gpx:rte/gpx:rtept//kashmir3d:icon[.!='903001']">
  <xsl:sort select="."/>
  <tmp:icon><xsl:value-of select="."/></tmp:icon>
 </xsl:for-each>
</xsl:variable>
<xsl:variable name="icons" select="exsl:node-set($tmp)"/>

<xsl:template match="/">
 <xsl:comment><xsl:value-of select="concat($VERSION,' ',date:date-time())"/></xsl:comment>
 <xsl:apply-templates select="gpx:gpx"/>
</xsl:template>

<xsl:template match="gpx:gpx">
 <kml>
  <Document>
   <xsl:apply-templates select="gpx:metadata"/>
   <xsl:apply-templates select="gpx:rte|gpx:trk" mode="LineStyle"/>
   <xsl:for-each select="$icons/tmp:icon">
    <xsl:if test="not(preceding-sibling::tmp:icon[.=current()])">
     <xsl:call-template name="IconStyle">
      <xsl:with-param name="icon" select="$iconlut/icon[@code=current()]"/>
     </xsl:call-template>
    </xsl:if>
   </xsl:for-each>
   <Folder>
    <name>Route</name>
    <xsl:apply-templates select="gpx:rte" mode="LineString"/>
   </Folder>
   <Folder>
    <name>Track</name>
    <xsl:apply-templates select="gpx:trk" mode="LineString"/>
   </Folder>
   <Folder>
    <name>Waypoint</name>
    <xsl:apply-templates select="gpx:wpt|gpx:rte/gpx:rtept[.//kashmir3d:icon!='903001']"/>
   </Folder>
  </Document>
 </kml>
</xsl:template>

<xsl:template name="IconStyle">
 <xsl:param name="icon"/>
 <xsl:param name="id" select="concat('N',$icon/@code)"/>
 <Style id="{$id}">
  <IconStyle>
   <scale>1</scale>
   <Icon>
    <href>
     <xsl:value-of select="$icon/@src"/>
     <xsl:if test="starts-with($icon/@src,'http:')">
       <xsl:value-of select="concat('#',$id,'.',$icon/@size,'.',$icon/@size)"/>
     </xsl:if>
    </href>
   </Icon>
   <hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
  </IconStyle>
  <LabelStyle>
   <color>ffffffff</color>
   <scale>0.75</scale>
  </LabelStyle>
 </Style>
</xsl:template>

<xsl:template match="gpx:metadata">
 <name><xsl:value-of select="gpx:name"/></name>
 <Snippet><xsl:value-of select="concat('作成日 ',gpx:time)"/></Snippet>
 <xsl:apply-templates select="gpx:author"/>
</xsl:template>

<xsl:template match="gpx:author">
 <atom:author>
  <atom:name><xsl:value-of select="gpx:name"/></atom:name>
 </atom:author>
 <atom:link href="{gpx:link/@href}"/>
</xsl:template>

<xsl:template match="gpx:rte|gpx:trk" mode="LineStyle">
 <Style id="{generate-id()}">
  <LineStyle>
   <xsl:apply-templates select="gpx:extensions/kashmir3d:line_color"/>
   <xsl:apply-templates select="gpx:extensions/kashmir3d:line_size"/>
  </LineStyle>
 </Style>
</xsl:template>

<xsl:template match="kashmir3d:line_color">
 <color><xsl:value-of select="concat($ALPHA,.)"/></color>
</xsl:template>

<xsl:template match="kashmir3d:line_size">
 <width><xsl:value-of select="."/></width>
</xsl:template>

<xsl:template match="gpx:rte" mode="LineString">
 <Placemark>
  <name><xsl:value-of select="gpx:name"/></name>
  <styleUrl><xsl:value-of select="concat('#',generate-id())"/></styleUrl>
  <xsl:call-template name="LineString"/>
 </Placemark>
</xsl:template>

<xsl:template match="gpx:trk" mode="LineString">
 <xsl:for-each select="gpx:trkseg">
  <Placemark>
   <name><xsl:value-of select="../gpx:name"/></name>
   <styleUrl><xsl:value-of select="concat('#',generate-id(..))"/></styleUrl>
   <xsl:call-template name="LineString"/>
  </Placemark>
 </xsl:for-each>
</xsl:template>

<xsl:template name="LineString">
 <LineString>
  <coordinates>
   <xsl:for-each select="gpx:rtept|gpx:trkpt">
    <xsl:value-of select="concat(
     format-number(@lon,'#.000000'),',',
     format-number(@lat,'#.000000'),',',
     format-number(gpx:ele,'#.00'),'&#10;'
    )"/>
   </xsl:for-each>
  </coordinates>
 </LineString>
</xsl:template>

<xsl:template match="gpx:wpt|gpx:rtept">
 <Placemark>
  <name><xsl:value-of select="gpx:name"/></name>
  <xsl:apply-templates select="gpx:cmt[not(.='' or .='*=' or .='&#x3000;=&#x3000;')]"/>
  <xsl:apply-templates select="gpx:extensions/kashmir3d:icon"/>
  <Point>
   <coordinates>
    <xsl:value-of select="concat(
     format-number(@lon,'#.000000'),',',
     format-number(@lat,'#.000000'),',',
     format-number(gpx:ele,'#.00')
    )"/>
   </coordinates>
  </Point>
 </Placemark>
</xsl:template>

<xsl:template match="gpx:cmt">
 <xsl:param name="c" select="str:split(.,',')"/>
 <description>
  <xsl:text><![CDATA[<table>]]></xsl:text>
  <xsl:for-each select="$c[not(starts-with(.,'@'))]">
   <xsl:text><![CDATA[<tr><td>]]></xsl:text>
   <xsl:value-of select="substring-before(.,'=')"/>
   <xsl:text><![CDATA[</td><td>]]></xsl:text>
   <xsl:choose>
    <xsl:when test="substring-before(.,'=')='URL'">
     <xsl:value-of select="concat('&lt;a href=&quot;',
      substring-after(.,'='),'&quot;&gt;',
      substring-after(.,'='),'&lt;/a&gt;'
     )"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="substring-after(.,'=')"/>
    </xsl:otherwise>
   </xsl:choose>
   <xsl:text><![CDATA[</td></tr>]]></xsl:text>
  </xsl:for-each>
  <xsl:text><![CDATA[</table>]]></xsl:text>
 </description>
</xsl:template>

<xsl:template match="kashmir3d:icon">
 <xsl:param name="icon" select="$iconlut/icon[@code=current()]"/>
 <styleUrl><xsl:value-of select="concat('#N',.)"/></styleUrl>
</xsl:template>

</xsl:stylesheet>
