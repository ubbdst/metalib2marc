<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:flub="http://data.ub.uib.no/xsl/function-library"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim"
    exclude-result-prefixes="xs flub xsi" version="2.0">
    <xsl:strip-space elements="*"/>
    <xsl:output indent="yes" method="xml"/>
    <!-- stylesheet to transform from metalib dump to normarc import for bibsys consortium-->
    <xsl:param name="institution" select="'UBB'" as="xs:string"/>

    <xsl:param name="languages" select="'en nb'"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:variable name="controlfield_008" as="node()">
        <controlfield tag="008">#########################################</controlfield>
    </xsl:variable>

    <xsl:key name="category-by-id" match="*" use="@id"/>
    <xsl:template match="*:file" priority="1.0">
        <xsl:variable name="categories" select="document('categories.xml')"/>
      
        <records xmlns="http://www.loc.gov/MARC21/slim">
         
                  <xsl:apply-templates>
                <xsl:with-param name="categories" tunnel="yes" select="$categories"/>
            </xsl:apply-templates>
         
           </records>
    </xsl:template>

       <xsl:template match="*" priority="0.5">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- explicitly just selecting record child(ren)-->
    <xsl:template match="*:knowledge_unit">
        <xsl:apply-templates select="*:record"/>
    </xsl:template>

    <xsl:template match="text()" mode="copy sort">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="text()"/>

    <xsl:template match="*" mode="copy sort">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="copy"/>
        </xsl:element>
    </xsl:template>

    <!-- Removed because of unused fields in marc. Should some of these be remapped?
         Github issues.
    -->

    <xsl:template
        match="
            *:datafield[@tag = ('531', '532', '574',
            '575', '591', '592', '593', '594', '595', '901', '902', '956') and *:subfield/@code = 'a'] |
            *:datafield[@tag = '856']/*:subfield[@code = ('7', 'D')] |
            *:datafield[@tag = '245']/*:subfield[@code = '9']"
        priority="2.0" mode="copy #default"/>

    <xsl:template match="*:datafield[matches(@tag, '^[0-9]+')]|*:controlfield[matches(@tag, '^[0-9]+')]" priority="1.8">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="copy"/>
        </xsl:element>        
    </xsl:template>
   
    <xsl:template
        match="
            *:datafield[@tag = '520'] |
            *:datafield[@tag = '245' and *:subfield/@code = 'a'] |
            *:datafield[@tag = '246' and *:subfield/@code = 'a'] |
            *:datafield[@tag = '260' and (*:subfield/@code = 'a' or *:subfield/@code = 'b')]"
        priority="2.1">
        <xsl:element name="{local-name()}">

            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="copy"/>

        </xsl:element>
    </xsl:template>

    <xsl:template name="controlfield_008">
        <xsl:sequence
            select="
                flub:replaceFieldInPosition(
                flub:replaceFieldInPosition(
                flub:replaceFieldInPosition(
                flub:replaceFieldInPosition($controlfield_008
                , 18, 'k')
                , 21, 'd')
                , 23, 'o')
                , 34, '2')"
        />
    </xsl:template>

    <!-- Our metalib contains many inactive items. Only use records with: 
        <datafield tag="STA" ind1=" " ind2=" ">
    <subfield code="a">ACTIVE</subfield>
  </datafield>
    -->
    <xsl:template match="*:record[*:datafield[@tag = 'STA']/*:subfield[@code = 'a'] = 'ACTIVE']"
        priority="1.0">
        <xsl:variable name="record">
            <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:call-template name="leader"/>
            <xsl:call-template name="controlfield_008"/>
            <xsl:variable name="conditionForOA" as="xs:boolean">
                <xsl:sequence
                    select="
                        if (*:datafield[@tag = '594']/subfield[@code = 'a'
                        and matches(., 'FREE', 'i')]
                        )
                        then
                            true()
                        else
                            false()"
                />
            </xsl:variable>
            <xsl:apply-templates>
                <xsl:with-param name="OA" select="$conditionForOA" tunnel="yes"/>
            </xsl:apply-templates>

            <!-- apply category from outside of record. Only go to first of each main category, 
            to nest the categories -->
            <xsl:apply-templates
                select="parent::*:knowledge_unit/*:category/(*:main except *:main[preceding-sibling::*:main = .])"
                mode="datafield_920"/>

            <xsl:if test="$conditionForOA">
                <datafield tag="999">
                    <subfield code="a">OA</subfield>
                </datafield>
            </xsl:if>
        </xsl:element>
        </xsl:variable>
        <!-- sorting records based on tag, ind1 and ind2-->
        <record>
            <xsl:apply-templates mode="sort" select="$record/descendant-or-self::*:record/*">
            <xsl:sort select="@tag"/>
            <xsl:sort select="@ind1"/>
            <xsl:sort select="@ind2"/>
        </xsl:apply-templates>
        </record>
    </xsl:template>

    <xsl:template match="*:datafield"/>

    <xsl:template
        match="*:datafield[@tag = '856' and @ind1 = '4' and (@ind2 = '1' or @ind2 = '9') and *:subfield/@code = 'u']"
        priority="2.5">
        <datafield tag="{if (@ind2='9') then 956
                else 921}" ind1=" " ind2=" ">
            <subfield code="u">
                <xsl:value-of select="*:subfield[@code = 'u']"/>
            </subfield>
            <xsl:call-template name="subfield_code_5"/>
        </datafield>
    </xsl:template>

    <xsl:template mode="datafield_920" match="*:category/*:main">
        <xsl:param name="categories" tunnel="yes" as="node()"/>
        <xsl:variable name="this_context" select="."/>
        <xsl:for-each select="tokenize($languages, '\s')">
            <xsl:variable name="lang" select="."/>
            <datafield tag="920" ind1=" " ind2=" ">
                <xsl:variable name="current-cat"
                    select="key('category-by-id', $this_context, $categories)"/>
                <xsl:if test="not($current-cat/(@* except @id))">
                    <xsl:message terminate="yes">Finner inngen språk attributter for <xsl:value-of
                            select="$this_context"/> Opprett 'en' eller 'nb' translations i
                            <xsl:value-of select="base-uri($categories)"/></xsl:message>
                </xsl:if>
                <subfield code="a">
                    <xsl:value-of select="$current-cat/@*[name() = $lang]"/>
                </subfield>
                <xsl:variable name="sub-context" select="$this_context/following-sibling::*[1]"/>
                <xsl:for-each
                    select="$this_context/following-sibling::*:sub[preceding-sibling::*[1]/text() = $this_context]">
                    <xsl:variable name="sub-cat"
                        select="key('category-by-id', ., $current-cat)/@*[name() = $lang]"/>
                    <subfield code="b">
                        <xsl:value-of select="$sub-cat"/>
                    </subfield>
                </xsl:for-each>
                <xsl:call-template name="subfield_code_5"/>
                <subfield code="9">
                    <xsl:value-of
                        select="
                            if (. = 'en') then
                                'eng'
                            else
                                'nor'"
                    />
                </subfield>
            </datafield>
        </xsl:for-each>
    </xsl:template>

    <!-- remove all datafields which are not covered by the general rule-->
    <xsl:template match="*:datafield" priority="0.7"/>

    <!-- remove all records which are not ACTIVE-->
    <xsl:template match="*:record" priority="0.7"/>

    <xsl:function name="flub:replaceFieldInPosition">
        <xsl:param name="controlfield" as="node()"/>
        <xsl:param name="position" as="xs:integer"/>
        <xsl:param name="insert_value" as="xs:string"/>
        <!-- to replace sibling values we use the length of the insert value-->
        <xsl:variable name="length" select="string-length($insert_value)"/>
        <xsl:if test="not($controlfield/local-name() = 'controlfield')">
            <xsl:message terminate="yes"> flub:replaceFieldInPosition: not controlfield
            </xsl:message>
        </xsl:if>
        <!-- 008 first index position is 00, so starting position is -->
        <xsl:variable name="marc-position" select="$position"/>
        <xsl:variable name="regexp"
            select="concat('^([\s\S]{', $marc-position, '})[\s\S]{', $length, '}')"/>

        <xsl:variable name="controlfield_out" as="node()">
            <xsl:for-each select="$controlfield">
                <xsl:element name="{local-name()}">
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="replace(., $regexp, concat('$1', $insert_value))"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$position &lt; 0 or $position &gt; string-length($controlfield)">
            <xsl:message terminate="yes">flub:replaceFieldInPosition $position <xsl:value-of
                    select="$position"/> out of bounds. </xsl:message>
        </xsl:if>

        <xsl:if test="string-length($controlfield) != string-length($controlfield_out)">
            <xsl:message terminate="yes"> flub:replaceFieldInPosition(): controlfield out of bounds.
            </xsl:message>
        </xsl:if>
        <xsl:sequence select="$controlfield_out"/>

    </xsl:function>

    <xsl:template name="subfield_code_5">
        <subfield code="5">
            <xsl:value-of select="$institution"/>
        </subfield>
    </xsl:template>

    <xsl:template name="leader">
        <leader>00000nai</leader>
    </xsl:template>

</xsl:stylesheet>