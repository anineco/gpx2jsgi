<?xml version="1.0" encoding="UTF-8"?>
<!-- center.xsl: Copyright (C) 2009-2011 anineco@nifty.com -->
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:gpx="http://www.topografix.com/GPX/1/1"
 xmlns:exsl="http://exslt.org/common"
 xmlns:math="http://exslt.org/math"
 extension-element-prefixes="exsl math">
<xsl:output method="text" encoding="UTF-8"/>

<xsl:variable name="tmp">
 <xsl:for-each select="//gpx:rtept|//gpx:trkpt|//gpx:wpt">
  <pt lat="{@lat}" lon="{@lon}" name="{local-name()}"/>
 </xsl:for-each>
</xsl:variable>
<xsl:variable name="pts" select="exsl:node-set($tmp)"/>
<xsl:variable name="CY" select="(math:max($pts/pt/@lat) + math:min($pts/pt/@lat)) div 2"/>
<xsl:variable name="CX" select="(math:max($pts/pt/@lon) + math:min($pts/pt/@lon)) div 2"/>

<xsl:template match="gpx:gpx">
 <xsl:value-of select="concat(count(//gpx:trkpt),' ',
  format-number($CY,'#.000000'),' ',
  format-number($CX,'#.000000'),'&#10;')"/>
</xsl:template>

</xsl:stylesheet>
