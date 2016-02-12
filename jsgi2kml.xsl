<?xml version="1.0" encoding="UTF-8"?>
<!-- jsgi2kml.xsl: Copyright (C) 2013 anineco@nifty.com -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns="http://www.opengis.net/kml/2.2"
 xmlns:atom="http://www.w3.org/2005/Atom"
 xmlns:date="http://exslt.org/dates-and-times"
 xmlns:exsl="http://exslt.org/common"
 xmlns:func="http://exslt.org/functions"
 xmlns:str="http://exslt.org/strings"
 xmlns:my="urn:my" xmlns:tmp="urn:tmp"
 extension-element-prefixes="date exsl func str my"
 exclude-result-prefixes="tmp">
<xsl:output method="xml" encoding="UTF-8" indent="yes"
 cdata-section-elements="description"/>

<xsl:param name="VERSION">JSGI2KML Ver.1.4</xsl:param>
<xsl:param name="ICONSIZE">24.24</xsl:param>
<xsl:param name="ALPHA">b3</xsl:param>

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

<xsl:variable name="tmp">
 <xsl:for-each select="//layer/style/symbol/uri[.!='']">
  <xsl:sort select="."/>
  <tmp:icon id="{generate-id()}"><xsl:value-of select="."/></tmp:icon>
 </xsl:for-each>
</xsl:variable>
<xsl:variable name="icons" select="exsl:node-set($tmp)"/>

<xsl:template match="/">
 <xsl:comment><xsl:value-of select="concat($VERSION,' ',date:date-time())"/></xsl:comment>
 <xsl:apply-templates select="GI"/>
</xsl:template>

<xsl:template match="GI">
 <kml>
  <Document>
   <xsl:apply-templates select="exchangeMetadata"/>
   <xsl:apply-templates select="dataset/layer[style/type='string']" mode="LineStyle"/>
   <xsl:for-each select="$icons/tmp:icon">
    <xsl:if test="not(preceding-sibling::tmp:icon[.=current()])">
     <Style id="{@id}">
      <IconStyle>
       <scale>1</scale>
       <Icon>
        <href><xsl:value-of select="concat(.,'#',@id,'.',$ICONSIZE)"/></href>
       </Icon>
       <hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
      </IconStyle>
      <LabelStyle>
       <color>ffff0000</color>
       <scale>1.1</scale>
      </LabelStyle>
     </Style>
    </xsl:if>
   </xsl:for-each>
   <Folder>
    <name>Route</name>
    <xsl:apply-templates select="dataset/layer[style/type='string' and name='Route']" mode="LineString"/>
   </Folder>
   <Folder>
    <name>Track</name>
    <xsl:apply-templates select="dataset/layer[style/type='string' and name!='Route']" mode="LineString"/>
   </Folder>
   <Folder>
    <name>Waypoint</name>
    <xsl:apply-templates select="dataset/layer[style/type='symbol' and style/symbol/uri!='']" mode="Point"/>
   </Folder>
  </Document>
 </kml>
</xsl:template>

<xsl:template match="exchangeMetadata">
 <name><xsl:value-of select="datasetCitation/title"/></name>
 <Snippet><xsl:value-of select="concat('作成日 ',datasetCitation/date/date)"/></Snippet>
 <xsl:apply-templates select="citedResponsibleParty"/>
</xsl:template>

<xsl:template match="citedResponsibleParty">
 <atom:author>
  <atom:name><xsl:value-of select="individualName"/></atom:name>
 </atom:author>
 <atom:link href="{contactInfo//linkage}"/>
</xsl:template>

<xsl:template match="layer" mode="LineStyle">
 <Style id="{generate-id()}">
  <LineStyle>
   <xsl:apply-templates select="style/rgb"/>
   <xsl:apply-templates select="style/width"/>
  </LineStyle>
 </Style>
</xsl:template>

<xsl:template match="rgb">
 <xsl:param name="c" select="str:split(.,',')"/>
 <color>
  <xsl:value-of select="concat($ALPHA,
   my:tohex(floor($c[3] div 16)), my:tohex($c[3] mod 16),
   my:tohex(floor($c[2] div 16)), my:tohex($c[2] mod 16),
   my:tohex(floor($c[1] div 16)), my:tohex($c[1] mod 16)
  )"/>
 </color>
</xsl:template>

<xsl:template match="width">
 <width><xsl:value-of select="substring-before(.,',')"/></width>
</xsl:template>

<xsl:template match="layer" mode="LineString">
 <Placemark>
  <name><xsl:value-of select="substring-before(style/name,'.')"/></name>
  <styleUrl><xsl:value-of select="concat('#',generate-id())"/></styleUrl>
  <LineString>
   <coordinates>
    <xsl:for-each select="curve//coordinate|Curve//coordinate">
     <xsl:value-of select="concat(substring-before(.,' '),',',substring-after(.,' '),'&#10;')"/>
    </xsl:for-each>
   </coordinates>
  </LineString>
 </Placemark>
</xsl:template>

<xsl:template match="layer" mode="Point">
 <Placemark>
  <name><xsl:value-of select="point/name"/></name>
  <xsl:apply-templates select="point/attribute[not(.='' or .='*=' or .='&#x3000;=&#x3000;')]"/>
  <xsl:apply-templates select="style/symbol/uri"/>
  <Point>
   <coordinates>
    <xsl:for-each select="point//coordinate">
     <xsl:value-of select="concat(substring-before(.,' '),',',substring-after(.,' '))"/>
    </xsl:for-each>
   </coordinates>
  </Point>
 </Placemark>
</xsl:template>

<xsl:template match="attribute">
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

<xsl:template match="uri">
 <styleUrl><xsl:value-of select="concat('#',$icons/tmp:icon[.=current()]/@id)"/></styleUrl>
</xsl:template>

</xsl:stylesheet>
