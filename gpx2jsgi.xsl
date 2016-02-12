<?xml version="1.0" encoding="UTF-8"?>
<!-- gpx2jsgi.xsl: Copyright (C) 2008-2013 anineco@nifty.com -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns:gpx="http://www.topografix.com/GPX/1/1"
 xmlns:kashmir3d="http://www.kashmir3d.com/namespace/kashmir3d"
 xmlns:date="http://exslt.org/dates-and-times"
 xmlns:func="http://exslt.org/functions"
 xmlns:str="http://exslt.org/strings"
 xmlns:my="urn:my"
 extension-element-prefixes="date func str my"
 exclude-result-prefixes="gpx kashmir3d">
<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

<xsl:param name="VERSION">GPX2JSGI Ver.1.5</xsl:param>
<xsl:param name="ICONLUT">iconlut.xml</xsl:param>
<xsl:param name="iconlut" select="document($ICONLUT,/)/iconlut"/>

<func:function name="my:hexchar">
 <xsl:param name="c"/>
 <func:result>
  <xsl:choose>
   <xsl:when test="$c='A' or $c='a'">10</xsl:when>
   <xsl:when test="$c='B' or $c='b'">11</xsl:when>
   <xsl:when test="$c='C' or $c='c'">12</xsl:when>
   <xsl:when test="$c='D' or $c='d'">13</xsl:when>
   <xsl:when test="$c='E' or $c='e'">14</xsl:when>
   <xsl:when test="$c='F' or $c='f'">15</xsl:when>
   <xsl:otherwise><xsl:value-of select="$c"/></xsl:otherwise>
  </xsl:choose>
 </func:result>
</func:function>

<xsl:template match="/">
 <xsl:comment><xsl:value-of select="concat($VERSION,' ',date:date-time())"/></xsl:comment>
 <xsl:apply-templates select="gpx:gpx"/>
</xsl:template>

<xsl:template match="gpx:gpx">
 <GI timeStamp="{date:date-time()}" version="1.0">
  <xsl:apply-templates select="gpx:metadata"/>
  <dataset>
   <xsl:apply-templates select="gpx:rte"/>
   <xsl:apply-templates select="gpx:trk"/>
   <xsl:apply-templates select="gpx:wpt" mode="symbol"/>
   <xsl:apply-templates select="gpx:rte/gpx:rtept[.//kashmir3d:icon!='903001']" mode="symbol"/>
  </dataset>
 </GI>
</xsl:template>

<xsl:template match="gpx:metadata">
 <exchangeMetadata>
  <datasetCitation>
   <title><xsl:value-of select="gpx:name"/></title>
   <date>
    <date><xsl:value-of select="gpx:time"/></date>
    <dateType>creation</dateType>
   </date>
  </datasetCitation>
  <citedResponsibleParty>
   <xsl:apply-templates select="gpx:author"/>
  </citedResponsibleParty>
  <encodingRule>
   <encodingRuleCitation>
    <title>地理情報標準第２版電子国土プロファイル</title>
    <date>
     <date>2005-03-29</date>
    </date>
   </encodingRuleCitation>
   <toolName><xsl:value-of select="$VERSION"/></toolName>
  </encodingRule>
 </exchangeMetadata>
</xsl:template>

<xsl:template match="gpx:author">
 <individualName><xsl:value-of select="gpx:name"/></individualName>
 <contactInfo>
  <onlineResource>
   <linkage><xsl:value-of select="gpx:link/@href"/></linkage>
   <name><xsl:value-of select="gpx:link/gpx:text"/></name>
  </onlineResource>
  <address>
   <electronicMailAddress>
    <xsl:value-of select="concat(gpx:email/@id,'@',gpx:email/@domain)"/>
   </electronicMailAddress>
  </address>
 </contactInfo>
 <role>resourceProvider</role>
</xsl:template>

<xsl:template match="gpx:wpt|gpx:rtept" mode="symbol">
 <layer>
  <name>Waypoint</name>
  <style>
   <name><xsl:value-of select="concat(gpx:name,'.',generate-id())"/></name>
   <type>symbol</type>
   <display>on</display>
   <transparent>off</transparent>
   <selection>on</selection>
   <displaylevel>all</displaylevel>
   <xsl:apply-templates select="gpx:extensions/kashmir3d:icon"/>
  </style>
  <point>
   <point>
    <CRS uuidref="JGD2000 / (L, B)"/>
    <position><xsl:call-template name="coordinate"/></position>
   </point>
   <name><xsl:value-of select="gpx:name"/></name>
   <attribute><xsl:value-of select="gpx:cmt"/></attribute>
  </point>
 </layer>
</xsl:template>

<xsl:template match="gpx:rte">
 <layer>
  <name>Route</name>
  <xsl:call-template name="style"/>
  <xsl:call-template name="curve"/>
 </layer>
</xsl:template>

<xsl:template match="gpx:trk">
 <layer>
  <name>Track</name>
  <xsl:call-template name="style"/>
  <xsl:for-each select="gpx:trkseg">
   <xsl:call-template name="curve"/>
  </xsl:for-each>
 </layer>
</xsl:template>

<xsl:template match="kashmir3d:icon">
 <xsl:param name="icon" select="$iconlut/icon[@code=current()]"/>
 <symbol>
  <xsl:call-template name="debug"/>
  <uri><xsl:value-of select="$icon/@src"/></uri>
  <size><xsl:value-of select="concat($icon/@size,',static')"/></size>
 </symbol>
</xsl:template>

<xsl:template match="kashmir3d:line_color">
 <xsl:param name="c" select="str:split(.,'')"/>
 <rgb>
  <xsl:value-of select="concat(
   my:hexchar($c[5]) * 16 + my:hexchar($c[6]),',',
   my:hexchar($c[3]) * 16 + my:hexchar($c[4]),',',
   my:hexchar($c[1]) * 16 + my:hexchar($c[2])
  )"/>
 </rgb>
</xsl:template>

<xsl:template match="kashmir3d:line_size">
 <xsl:call-template name="debug"/>
 <width><xsl:value-of select="concat(.,',static')"/></width>
</xsl:template>

<xsl:template match="kashmir3d:line_style">
 <xsl:call-template name="debug"/>
 <style kind="system">
  <xsl:choose>
   <xsl:when test=".=11">dash</xsl:when>
   <xsl:when test=".=12">dash</xsl:when>
   <xsl:when test=".=13">dot</xsl:when>
   <xsl:when test=".=14">dashdot</xsl:when>
   <xsl:when test=".=15">dashdotdot</xsl:when>
   <xsl:otherwise>solid</xsl:otherwise>
  </xsl:choose>
 </style>
</xsl:template>

<xsl:template name="debug">
 <xsl:comment><xsl:value-of select="concat(name(),' ',.)"/></xsl:comment>
</xsl:template>

<xsl:template name="style">
 <style>
  <name><xsl:value-of select="concat(gpx:name,'.',generate-id())"/></name>
  <type>string</type>
  <display>on</display>
  <transparent>on</transparent>
  <selection>off</selection>
  <displaylevel>all</displaylevel>
  <xsl:apply-templates select="gpx:extensions/kashmir3d:line_color"/>
  <xsl:apply-templates select="gpx:extensions/kashmir3d:line_style"/>
  <xsl:apply-templates select="gpx:extensions/kashmir3d:line_size"/>
 </style>
</xsl:template>

<xsl:template name="curve">
 <curve>
  <GM_Curve id="{generate-id()}">
   <CRS uuidref="JGD2000 / (L, B)"/>
   <orientation>+</orientation>
   <primitive idref="{generate-id()}"/>
   <segment>
    <GM_LineString>
     <interpolation>linear</interpolation>
     <controlPoint>
      <xsl:apply-templates select="gpx:rtept|gpx:trkpt" mode="string"/>
     </controlPoint>
    </GM_LineString>
   </segment>
  </GM_Curve>
 </curve>
</xsl:template>

<xsl:template match="gpx:rtept|gpx:trkpt" mode="string">
 <column>
  <direct><xsl:call-template name="coordinate"/></direct>
 </column>
</xsl:template>

<xsl:template name="coordinate">
 <coordinate>
  <xsl:value-of select="concat(
   format-number(@lon,'#.000000'),' ',
   format-number(@lat,'#.000000')
  )"/>
 </coordinate>
</xsl:template>

</xsl:stylesheet>
