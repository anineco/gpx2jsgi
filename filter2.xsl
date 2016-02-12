<?xml version="1.0" encoding="UTF-8"?>
<!-- filter2.xsl: Copyright (C) 2010-2011 anineco@nifty.com -->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:gpx="http://www.topografix.com/GPX/1/1"
 xmlns:kashmir3d="http://www.kashmir3d.com/namespace/kashmir3d">
<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
<xsl:param name="trk" select="document('aux2.gpx',/)/gpx:gpx/gpx:trk"/>

<xsl:template match="gpx:gpx">
 <xsl:copy>
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates select="gpx:metadata"/>
  <xsl:apply-templates select="gpx:wpt"/>
  <xsl:apply-templates select="gpx:rte"/>
  <xsl:for-each select="gpx:trk">
   <xsl:copy>
    <xsl:apply-templates select="gpx:name"/>
    <xsl:apply-templates select="gpx:cmt"/>
    <xsl:apply-templates select="gpx:desc"/>
    <xsl:apply-templates select="gpx:src"/>
    <xsl:apply-templates select="gpx:link"/>
    <xsl:apply-templates select="gpx:number"/>
    <xsl:apply-templates select="gpx:type"/>
    <xsl:apply-templates select="gpx:extensions"/>
    <xsl:call-template name="trksegs">
     <xsl:with-param name="n" select="position()"/>
    </xsl:call-template>
   </xsl:copy>
  </xsl:for-each>
  <xsl:apply-templates select="gpx:extensions"/>
 </xsl:copy>
</xsl:template>

<xsl:template name="trksegs">
 <xsl:param name="n"></xsl:param>
 <xsl:apply-templates select="$trk[$n]/gpx:trkseg"/>
</xsl:template>

<xsl:template match="@*|node()">
 <xsl:copy>
  <xsl:apply-templates select="@*|node()"/>
 </xsl:copy>
</xsl:template>

</xsl:stylesheet>
