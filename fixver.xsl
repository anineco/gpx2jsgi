<?xml version="1.0" encoding="UTF-8"?>
<!-- fixver.xsl: Copyright (C) 2010-2011 anineco@nifty.com -->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:gpx10="http://www.topografix.com/GPX/1/0"
 xmlns:kashmir3d="http://www.kashmir3d.com/namespace/kashmir3d"
 xmlns="http://www.topografix.com/GPX/1/1"
 exclude-result-prefixes="gpx10">
<xsl:output method="xml" indent="yes" encoding="UTF-8"/>

<xsl:template match="gpx10:gpx">
 <gpx>
  <xsl:apply-templates select="@*|node()"/>
 </gpx>
</xsl:template>

<xsl:template match="gpx10:*">
 <xsl:element name="{local-name()}">
  <xsl:apply-templates select="@*|node()"/>
 </xsl:element>
</xsl:template>

<xsl:template match="@*|node()">
 <xsl:copy>
  <xsl:apply-templates select="@*|node()"/>
 </xsl:copy>
</xsl:template>

</xsl:stylesheet>
