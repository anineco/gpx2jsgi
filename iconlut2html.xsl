<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="iconlut">
 <html lang="ja">
  <head>
   <meta http-equiv="content-style-type" content="text/css"/>
   <title>アイコン変換表</title>
  </head>
  <body style="text-align: center;">
   <table cellspacing="0" cellpadding="2" border="1" style="text-align: left; margin: 30px auto 50px auto; background-color: #ccc;">
    <caption>アイコン変換表</caption>
    <tr>
     <th>コード番号</th>
     <th>説明</th>
     <th>画像</th>
     <th>size</th>
    </tr>
    <xsl:for-each select="icon">
     <xsl:sort select="@code" data-type="number"/>
     <xsl:if test="@src!=''">
      <tr>
       <td align="center"><xsl:value-of select="@code"/></td>
       <td><xsl:value-of select="."/></td>
       <td align="center"><img src="{@src}" width="{@size}" height="{@size}" title="{@src}"/></td>
       <td align="center"><xsl:value-of select="@size"/></td>
      </tr>
     </xsl:if>
    </xsl:for-each>
   </table>
  </body>
 </html>
</xsl:template>

</xsl:stylesheet>
