<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
 <xsl:strip-space  elements="*"/>
<xsl:output method="text"/>
    <xsl:variable name="nl" >
    <xsl:text>
</xsl:text>
</xsl:variable>    
    <xsl:template match="*:leader">
        <xsl:value-of select="replace(.,' ','#')"/><xsl:value-of select="$nl"/>
    </xsl:template>

<xsl:template match="*:record">
 <xsl:apply-templates/>
<xsl:value-of select="$nl"/>
<xsl:value-of select="$nl"/>
</xsl:template>
    <xsl:template match="*:datafield|*:controlfield">
 <xsl:value-of select="@tag"/><xsl:text> </xsl:text><xsl:value-of select="concat(replace(@ind1,' ','_'),replace(@ind2,' ','_'))"/><xsl:apply-templates select="*:subfield"/><xsl:if test="not(*)"><xsl:text> </xsl:text><xsl:value-of select="."/></xsl:if>   
<xsl:value-of select="$nl"/>
    </xsl:template>
    
    <xsl:template match="*:subfield">
      <xsl:text> |</xsl:text><xsl:value-of select="@code"/><xsl:text> </xsl:text><xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>