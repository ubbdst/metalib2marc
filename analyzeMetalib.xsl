<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:flub="http://data.ub.uib.no/xsl/function-library/"
    xmlns="http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
    exclude-result-prefixes="xs flub xsi"
    version="2.0">
    
    <!-- stylesheet for writing out the structure of a metalib dump-->
    
    <xsl:key name="lookup-example-by-xpath-attribute" match="*" use="@xpath"/>
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <xsl:variable name="examples">
            <examples >
             <xsl:apply-templates/>
        </examples>
        </xsl:variable>
        <examples xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd http://uniport.hosted.exlibrisgroup.com:80/aleph-cgi/load_schema.pl">
        <xsl:for-each select="distinct-values($examples/*:examples/*:analyze-wrapper/@xpath)">
            <xsl:sort select="."/>
            <xsl:apply-templates select="key('lookup-example-by-xpath-attribute',.,$examples)[1]" mode="copy">
                
            </xsl:apply-templates>
        </xsl:for-each>
        </examples>
    </xsl:template>
    
    <xsl:template match="*" mode="copy">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="copy"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- mapping to be ignored-->
    <xsl:template match="*:datafield[@tag='ZAT']|datafield[@tag='CAT' or @tag='AF1']/*:subfield[@code='a']"/>
    
    <!-- only write out xpaht for element with immediate text children, with non-space.-->
    <xsl:template match="*[child::text()[matches(.,'\S')]]">
        
        <analyze-wrapper xpath="{flub:WriteOutXpath(self::node(),'')}">
            <!-- copy element attribute- and child text node for example-->
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:if test="not(*)">
                <xsl:value-of select="."/>
                </xsl:if>
            </xsl:copy>           
        </analyze-wrapper>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="processing-instruction()"></xsl:template>
    <xsl:function name="flub:WriteOutXpath">
        <xsl:param name="current-element" as="node()"/>
        <xsl:param name="sofar" as="xs:string?"/>
        <xsl:variable name="parent-element" select="$current-element/parent::*"/>
        <xsl:variable name="element-string"><xsl:for-each select="$current-element">
            <xsl:variable name="attribute_values" as="xs:string*">
                <xsl:if test="@tag"><xsl:sequence select="concat('@tag:',@tag)"/></xsl:if> 
        <xsl:if test="not(matches(@ind1,'^\s$')) and @ind1"><xsl:sequence select="concat('@ind1:',@ind1)"/></xsl:if>
                <xsl:if test="not(matches(@ind2,'^\s$')) and @ind2"><xsl:sequence select="('@ind2:',@ind2)"/></xsl:if>
        <xsl:if test="@code"><xsl:sequence select="concat('@code:',@code)"/></xsl:if>
            </xsl:variable>
            
            <xsl:variable name="hasAttributes" as="xs:boolean" select="if (count($attribute_values[string(.)]) > 0) then true() else false()"/>
            <xsl:sequence select="concat('/',name(),if ($hasAttributes) then '[' else '',
              if (count($attribute_values) > 1) then string-join($attribute_values,' ') else $attribute_values
              ,if ($hasAttributes) then ']' else '')"></xsl:sequence>            
        </xsl:for-each>
        </xsl:variable>        
        <xsl:variable name="current-xpath-string" select="concat($element-string,$sofar)"/>
        <xsl:choose>
            <xsl:when test="$parent-element">
                <xsl:sequence select="flub:WriteOutXpath($parent-element,concat($element-string,$sofar))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$current-xpath-string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>