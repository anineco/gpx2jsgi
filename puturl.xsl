<?xml version="1.0" encoding="UTF-8"?>
<!-- puturl.xsl: Copyright (C) 2013 anineco@nifty.com -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns:kml="http://www.opengis.net/kml/2.2"
 xmlns:atom="http://www.w3.org/2005/Atom"
 xmlns:date="http://exslt.org/dates-and-times"
 extension-element-prefixes="date">
<xsl:output method="xml" encoding="UTF-8"
 cdata-section-elements="kml:description"/>

<xsl:param name="VERSION">GPX2KMZ Ver.1.3</xsl:param>
<xsl:param name="ICONLUT">templut.xml</xsl:param>
<xsl:param name="iconlut" select="document($ICONLUT,/)/iconlut"/>

<xsl:template match="/">
 <xsl:comment><xsl:value-of select="concat($VERSION,' ',date:date-time())"/></xsl:comment>
 <xsl:apply-templates select="kml:kml"/>
</xsl:template>

<xsl:template match="kml:href">
 <xsl:param name="id" select="../../../@id"/>
 <xsl:copy><xsl:value-of select="$iconlut/icon[@code=$id]/@src"/></xsl:copy>
</xsl:template>

<xsl:template match="@*|node()">
 <xsl:copy>
  <xsl:apply-templates select="@*|node()"/>
 </xsl:copy>
</xsl:template>

</xsl:stylesheet>
