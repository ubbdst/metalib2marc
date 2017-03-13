<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math"
    version="2.0">
    <xsl:output encoding="UTF-8" indent="yes"/>
    <xsl:param name="path" select="'language/html/ubb'"/>
    <!-- 
         Stylesheet to transform categories downloaded as html from metalib 
         > Categories Admin > Categories Display
         Change language by selecting "Change Portal Parameters" and choosing.
         Click each category and 
         looks up files in $path ("html/" as default), copies the form containing the language data, and structures the data as output.
         Expects filenames to have a underscore followed by a letters (language)-->
    
    <xsl:key name="main-cat" match="*:namesub_cat" use="."/>
    <xsl:key name="sub-cat" match="*:td[@class='TableRow' and following-sibling::*:td/*:input/@name='sub_display']" use="."></xsl:key>
    <xsl:template match="/">
        <!-- namesub_cat element, main category, key-->
        <xsl:variable name="category-documents">
            <root>
                <xsl:for-each
                    select="collection(concat(iri-to-uri($path), '?select=*htm*;on-error=ignore;parser=org.ccil.cowan.tagsoup.Parser'))">

                    <xsl:variable name="base-uri" select="base-uri(.)"/>
                     <!-- checks that the document has a required element used by metalib categories-->
                    <xsl:if test="not(exists(self::node()/descendant::*:namesub_cat))">
                        <xsl:message terminate="yes">html fragment file <xsl:value-of
                                select="$base-uri"/> does not contain category xml. Copy the frame
                            with the categories, not the full page.</xsl:message>
                    </xsl:if>
                    <xsl:variable name="language">
                        <xsl:if test="not(matches($base-uri, '_[a-z]{2}\.html?'))"> <xsl:message terminate="yes">
                           
                                <xsl:value-of select="$base-uri"/> missing language tag in AA
                                _AA.html? 
                        </xsl:message>
                        </xsl:if>
                        <xsl:value-of
                            select="lower-case(replace($base-uri, '^.+_([a-z]{2})\.html?$', '$1', 'i'))"
                        />
                    </xsl:variable>
                    <doc lang="{$language}">
                        <xsl:copy-of select="self::node()"/>
                    </doc>
                </xsl:for-each>
            </root>
        </xsl:variable>

        <xsl:variable name="main-category-ids"
            select="distinct-values($category-documents/descendant::*:namesub_cat)"/>
        <root>            
            <xsl:for-each select="$main-category-ids" >
                <cat1 id="{.}">
                    <xsl:variable name="sub-display-inputs" select="key('main-cat',.,$category-documents)/ancestor::*:form/descendant::*:input[@name='sub_display']"/>
                    <xsl:variable name="sub-categories-ids" select="distinct-values($sub-display-inputs/parent::*/preceding-sibling::*:td[1])"/>
                    
                    <xsl:for-each select="key('main-cat',.,$category-documents)">
                        <xsl:variable name="input-field" select="following::*:input[@name='subcategory_display'][1]"/>
                        <xsl:attribute name="{$input-field/ancestor::*:doc/@lang}" select="$input-field/@value"/>
                    </xsl:for-each>
                    
                    <xsl:for-each select="$sub-categories-ids">
                        <xsl:variable name="sub-category" select="key('sub-cat',.,$category-documents)"/>
                        <cat2 id="{.}">
                           <xsl:for-each select="$sub-category">
                               <xsl:attribute name="{ancestor::*:doc/@lang}">
                                   <xsl:value-of select="./following-sibling::*:td[1]/*:input[@name='sub_display']/@value"/>
                               </xsl:attribute>
                           </xsl:for-each>
                       </cat2> 
                    </xsl:for-each>                   
                </cat1>
            </xsl:for-each>
          </root>
    </xsl:template>


   

</xsl:stylesheet>