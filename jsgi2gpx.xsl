<?xml version="1.0" encoding="UTF-8"?>
<!-- jsgi2gpx.xsl: Copyright (C) 2013 anineco@nifty.com -->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns="http://www.topografix.com/GPX/1/1"
 xmlns:kashmir3d="http://www.kashmir3d.com/namespace/kashmir3d"
 xmlns:date="http://exslt.org/dates-and-times"
 xmlns:func="http://exslt.org/functions"
 xmlns:str="http://exslt.org/strings"
 xmlns:my="urn:my"
 extension-element-prefixes="date func str my">
<xsl:output method="xml" encoding="UTF-8" indent="yes"
 cdata-section-elements="cmt"/>

<xsl:param name="VERSION">JSGI2GPX Ver.1.5</xsl:param>
<xsl:param name="ICONLUT">iconlut.xml</xsl:param>
<xsl:param name="iconlut" select="document($ICONLUT,/)/iconlut"/>

<func:function name="my:tohex">
 <xsl:param name="c"/>
 <func:result>
  <xsl:choose>
   <xsl:when test="$c=10">a</xsl:when>
   <xsl:when test="$c=11">b</xsl:when>
   <xsl:when test="$c=12">c</xsl:when>
   <xsl:when test="$c=13">d</xsl:when>
   <xsl:when test="$c=14">e</xsl:when>
   <xsl:when test="$c=15">f</xsl:when>
   <xsl:otherwise><xsl:value-of select="$c"/></xsl:otherwise>
  </xsl:choose>
 </func:result>
</func:function>

<xsl:template match="/">
 <xsl:comment><xsl:value-of select="concat($VERSION,' ',date:date-time())"/></xsl:comment>
 <xsl:apply-templates select="GI"/>
</xsl:template>

<xsl:template match="GI">
 <gpx version="1.1" creator="{$VERSION}">
  <xsl:apply-templates select="exchangeMetadata"/>
  <xsl:apply-templates select="dataset"/>
 </gpx>
</xsl:template>

<xsl:template match="exchangeMetadata">
 <metadata>
  <name><xsl:value-of select="datasetCitation/title"/></name>
  <xsl:apply-templates select="citedResponsibleParty"/>
  <time><xsl:value-of select="datasetCitation/date/date"/></time>
 </metadata>
</xsl:template>

<xsl:template match="citedResponsibleParty">
 <author>
  <name><xsl:value-of select="individualName"/></name>
  <xsl:apply-templates select="contactInfo/address/electronicMailAddress"/>
  <link href="{contactInfo/onlineResource/linkage}">
   <text><xsl:value-of select="contactInfo/onlineResource/name"/></text>
  </link>
 </author>
</xsl:template>

<xsl:template match="electronicMailAddress">
 <email id="{substring-before(.,'@')}" domain="{substring-after(.,'@')}"/>
</xsl:template>

<xsl:template match="dataset">
 <xsl:apply-templates select="layer[style/type='string' and name='Route']" mode="Route"/>
 <xsl:apply-templates select="layer[style/type='string' and name!='Route']" mode="Track"/>
 <xsl:apply-templates select="layer[style/type='symbol']" mode="Waypoint"/>
</xsl:template>

<xsl:template match="layer" mode="Route">
 <rte>
  <xsl:call-template name="layer_style"/>
  <xsl:apply-templates select="curve//coordinate|Curve//coordinate" mode="Route"/>
 </rte>
</xsl:template>

<xsl:template match="layer" mode="Track">
 <trk>
  <xsl:call-template name="layer_style"/>
  <trkseg>
   <xsl:apply-templates select="curve//coordinate|Curve//coordinate" mode="Track"/>
  </trkseg>
 </trk>
</xsl:template>

<xsl:template name="layer_style">
 <name><xsl:value-of select="substring-before(style/name,'.')"/></name>
 <extensions>
  <xsl:apply-templates select="style/rgb"/>
  <xsl:apply-templates select="style/style"/>
  <xsl:apply-templates select="style/width"/>
 </extensions>
</xsl:template>

<xsl:template match="rgb">
 <xsl:param name="c" select="str:split(.,',')"/>
 <kashmir3d:line_color>
  <xsl:value-of select="concat(
   my:tohex(floor($c[3] div 16)), my:tohex($c[3] mod 16),
   my:tohex(floor($c[2] div 16)), my:tohex($c[2] mod 16),
   my:tohex(floor($c[1] div 16)), my:tohex($c[1] mod 16)
  )"/>
 </kashmir3d:line_color>
</xsl:template>

<xsl:template match="style">
 <kashmir3d:line_style>
  <xsl:choose>
   <xsl:when test=".='dash'">11</xsl:when>
   <xsl:when test=".='dot'">13</xsl:when>
   <xsl:when test=".='dashdot'">14</xsl:when>
   <xsl:when test=".='dashdotdot'">15</xsl:when>
   <xsl:otherwise>1</xsl:otherwise>
  </xsl:choose>
 </kashmir3d:line_style>
</xsl:template>

<xsl:template match="width">
 <kashmir3d:line_size>
  <xsl:value-of select="substring-before(.,',')"/>
 </kashmir3d:line_size>
</xsl:template>

<xsl:template match="coordinate" mode="Route">
 <xsl:param name="p" select="str:split(.)"/>
 <rtept lat="{$p[2]}" lon="{$p[1]}">
  <ele>-1</ele>
 </rtept>
</xsl:template>

<xsl:template match="coordinate" mode="Track">
 <xsl:param name="p" select="str:split(.)"/>
 <trkpt lat="{$p[2]}" lon="{$p[1]}">
  <ele>-1</ele>
 </trkpt>
</xsl:template>

<xsl:template match="layer" mode="Waypoint">
 <xsl:param name="p" select="str:split(point//coordinate)"/>
 <wpt lat="{$p[2]}" lon="{$p[1]}">
  <ele>-1</ele>
  <name><xsl:value-of select="point/name"/></name>
  <cmt><xsl:value-of select="point/attribute"/></cmt>
  <extensions>
   <xsl:apply-templates select="style/symbol/uri"/>
  </extensions>
 </wpt>
</xsl:template>

<xsl:template match="uri">
 <xsl:param name="code" select="$iconlut/icon[@src=current()]/@code"/>
 <kashmir3d:icon>
  <xsl:choose>
   <xsl:when test="$code"><xsl:value-of select="$code"/></xsl:when>
   <xsl:otherwise>901001</xsl:otherwise>
  </xsl:choose>
 </kashmir3d:icon>
</xsl:template>

</xsl:stylesheet>
