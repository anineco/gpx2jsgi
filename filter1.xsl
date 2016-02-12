<?xml version="1.0" encoding="UTF-8"?>
<!-- filter1.xsl: Copyright (C) 2010-2011 anineco@nifty.com -->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:gpx="http://www.topografix.com/GPX/1/1"
 xmlns:kashmir3d="http://www.kashmir3d.com/namespace/kashmir3d">
<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

<xsl:template match="gpx:gpx">
 <xsl:copy>
  <xsl:apply-templates select="@*"/>
  <xsl:for-each select="gpx:trk">
   <xsl:copy>
    <xsl:apply-templates select="gpx:trkseg"/>
   </xsl:copy>
  </xsl:for-each>
 </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()">
 <xsl:copy>
  <xsl:apply-templates select="@*|node()"/>
 </xsl:copy>
</xsl:template>

</xsl:stylesheet>
