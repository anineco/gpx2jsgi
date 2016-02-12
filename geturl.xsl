<?xml version="1.0" encoding="UTF-8"?>
<!-- geturl.xsl: Copyright (C) 2013 anineco@nifty.com -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns:kml="http://www.opengis.net/kml/2.2"
 xmlns:atom="http://www.w3.org/2005/Atom">
<xsl:output method="text" encoding="UTF-8"/>

<xsl:template match="/">
 <xsl:apply-templates select="//kml:href"/>
</xsl:template>

<xsl:template match="kml:href">
 <xsl:value-of select="concat('{ ',../../../@id,' ',.,'} ')"/>
</xsl:template>

</xsl:stylesheet>
